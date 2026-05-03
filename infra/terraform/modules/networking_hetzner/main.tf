terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.59"
    }
  }
}

resource "hcloud_network" "this" {
  name     = var.network_name
  ip_range = var.network_cidr
}

resource "hcloud_network_subnet" "mgmt" {
  network_id   = hcloud_network.this.id
  type         = "cloud"
  network_zone = var.network_zone
  ip_range     = var.mgmt_subnet_cidr
}

resource "hcloud_network_subnet" "ci" {
  network_id   = hcloud_network.this.id
  type         = "cloud"
  network_zone = var.network_zone
  ip_range     = var.ci_subnet_cidr
}
