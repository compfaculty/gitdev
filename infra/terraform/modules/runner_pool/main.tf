terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.59"
    }
  }
}

resource "hcloud_firewall" "runner" {
  count = var.runner_count
  name  = "${var.name_prefix}-runner-${count.index}-fw"

  rule {
    description = "SSH from mgmt subnet only (via bastion / VPN)"
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips  = [var.mgmt_subnet_cidr]
  }

  # No other ingress; runner initiates outbound jobs to GitLab HTTPS
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

resource "hcloud_server" "runner" {
  count       = var.runner_count
  name        = "${var.name_prefix}-runner-${count.index}"
  image       = var.server_image
  server_type = var.server_type
  location    = var.location
  ssh_keys    = var.ssh_key_ids

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  network {
    network_id = var.network_id
    ip         = var.private_ips != null ? var.private_ips[count.index] : null
  }

  firewall_ids = [hcloud_firewall.runner[count.index].id]

  labels = merge(var.labels, {
    role    = "gitlab_runner"
    tier    = var.tier
    pool_id = "${var.name_prefix}-${count.index}"
  })

  user_data = var.cloud_init_user_data
}
