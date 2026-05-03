terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.59"
    }
  }
}

resource "hcloud_firewall" "bastion" {
  name = "${var.instance_name}-fw"

  rule {
    description = "WireGuard ingress (narrow in production.tfvars)"
    direction   = "in"
    protocol    = "udp"
    port        = tostring(var.wireguard_port)
    source_ips  = length(var.vpn_ingress_allowlist) > 0 ? var.vpn_ingress_allowlist : ["0.0.0.0/0", "::/0"]
  }

  rule {
    description = "Emergency SSH bootstrap (prefer VPN-only ops after WG up)"
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips  = length(var.ssh_ingress_allowlist) > 0 ? var.ssh_ingress_allowlist : ["127.0.0.1/32"]
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

  rule {
    direction       = "out"
    protocol        = "icmp"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }
}

resource "hcloud_server" "bastion" {
  name        = var.instance_name
  image       = var.server_image
  server_type = var.server_type
  location    = var.location
  ssh_keys    = var.ssh_key_ids

  public_net {
    ipv4_enabled = true
    ipv6_enabled = var.ipv6_enabled
  }

  network {
    network_id = var.network_id
    ip         = var.private_ip != null ? var.private_ip : null
  }

  firewall_ids = [hcloud_firewall.bastion.id]

  labels = merge(var.labels, {
    role = "bastion_vpn_gateway"
  })

  user_data = var.cloud_init_user_data
}
