terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.59"
    }
  }
}

# Optional small public edge (nginx/Envoy) in front of ONE internal upstream — NOT for GitLab UI by default.
resource "hcloud_firewall" "edge" {
  name = "${var.name}-fw"

  rule {
    description = "HTTPS from CDN / WAF allowlist only"
    direction   = "in"
    protocol    = "tcp"
    port        = "443"
    source_ips  = length(var.cdn_source_cidrs) > 0 ? var.cdn_source_cidrs : ["127.0.0.1/32"]
  }

  rule {
    description = "HTTP redirect from CDN only (optional)"
    direction   = "in"
    protocol    = "tcp"
    port        = "80"
    source_ips  = length(var.cdn_source_cidrs) > 0 ? var.cdn_source_cidrs : ["127.0.0.1/32"]
  }

  rule {
    description = "Mgmt SSH from bastion/mgmt subnet only"
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips  = [var.mgmt_subnet_cidr]
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

resource "hcloud_server" "edge" {
  name        = var.name
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
    ip         = var.private_ip
  }

  firewall_ids = [hcloud_firewall.edge.id]

  labels = merge(var.labels, { role = "ingress_edge" })

  user_data = var.cloud_init_user_data
}
