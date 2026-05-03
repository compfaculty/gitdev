terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.59"
    }
  }
}

resource "hcloud_firewall" "gitlab" {
  name = "${var.instance_name}-fw"

  # Internal-only GitLab Omnibus NGINX HTTP/HTTPS
  rule {
    description = "GitLab HTTPS from private network"
    direction   = "in"
    protocol    = "tcp"
    port        = "443"
    source_ips = concat([
      var.mgmt_subnet_cidr,
      var.ci_subnet_cidr,
    ], length(var.additional_gitlab_https_sources) > 0 ? var.additional_gitlab_https_sources : [])
  }

  dynamic "rule" {
    for_each = var.enable_gitlab_ssh ? [1] : []
    content {
      description = "SSH from mgmt subnet"
      direction   = "in"
      protocol    = "tcp"
      port        = "22"
      source_ips  = [var.mgmt_subnet_cidr]
    }
  }

  rule {
    direction       = "out"
    protocol        = "tcp"
    port            = "1-65535"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction       = "out"
    protocol        = "udp"
    port            = "1-65535"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }
}

resource "hcloud_server" "gitlab" {
  name        = var.instance_name
  image       = var.server_image
  server_type = var.server_type
  location    = var.location
  ssh_keys    = var.ssh_key_ids

  public_net {
    ipv4_enabled = var.public_ipv4_enabled
    ipv6_enabled = false
  }

  network {
    network_id = var.network_id
    ip         = var.private_ip != null ? var.private_ip : null
  }

  firewall_ids = [hcloud_firewall.gitlab.id]

  labels = merge(var.labels, { role = "gitlab" })

  user_data = var.cloud_init_user_data
}
