locals {
  network_cidr     = "10.0.0.0/16"
  mgmt_subnet_cidr = "10.0.1.0/24"
  ci_subnet_cidr   = "10.0.2.0/24"
  common_labels = merge(var.tags, {
    project = var.project_name
    env     = "prod"
  })
}

resource "hcloud_ssh_key" "admin" {
  name       = "${var.project_name}-admin"
  public_key = var.ssh_public_key
}

module "networking" {
  source = "../../modules/networking_hetzner"

  network_name     = "${var.project_name}-net"
  network_cidr     = local.network_cidr
  mgmt_subnet_cidr = local.mgmt_subnet_cidr
  ci_subnet_cidr   = local.ci_subnet_cidr
  network_zone     = var.network_zone
}

module "bastion" {
  source = "../../modules/bastion"

  instance_name  = "${var.project_name}-bastion"
  location       = var.location
  ssh_key_ids    = [hcloud_ssh_key.admin.id]
  network_id     = module.networking.network_id
  private_ip     = "10.0.1.2"
  wireguard_port = 51820
  labels         = local.common_labels
  ipv6_enabled   = false

  vpn_ingress_allowlist = length(var.vpn_ingress_allowlist) > 0 ? var.vpn_ingress_allowlist : ["0.0.0.0/0", "::/0"]
  ssh_ingress_allowlist = length(var.ssh_bootstrap_allowlist) > 0 ? var.ssh_bootstrap_allowlist : ["127.0.0.1/32"]

  cloud_init_user_data = templatefile("${path.module}/templates/bastion-cloud-init.yaml.tpl", {})
}

module "gitlab_core" {
  source = "../../modules/gitlab_core"

  instance_name    = "${var.project_name}-gitlab"
  location         = var.location
  server_type      = var.gitlab_server_type
  ssh_key_ids      = [hcloud_ssh_key.admin.id]
  network_id       = module.networking.network_id
  private_ip       = "10.0.1.10"
  mgmt_subnet_cidr = local.mgmt_subnet_cidr
  ci_subnet_cidr   = local.ci_subnet_cidr
  labels           = local.common_labels

  # Public IPv4 enables outbound updates; firewall allows HTTPS/SSH only from private subnets + CI
  public_ipv4_enabled = true
}

module "runner_pool" {
  source = "../../modules/runner_pool"

  runner_count         = var.runner_count
  name_prefix          = var.project_name
  tier                 = "restricted"
  location             = var.location
  server_type          = var.runner_server_type
  ssh_key_ids          = [hcloud_ssh_key.admin.id]
  network_id           = module.networking.network_id
  mgmt_subnet_cidr     = local.mgmt_subnet_cidr
  private_ips          = [for i in range(var.runner_count) : cidrhost(local.ci_subnet_cidr, 20 + i)]
  labels               = local.common_labels
  cloud_init_user_data = ""
}

module "ingress_edge" {
  count  = var.enable_ingress_edge ? 1 : 0
  source = "../../modules/ingress_edge"

  name                 = "${var.project_name}-ingress"
  location             = var.location
  server_type          = var.ingress_edge_server_type
  ssh_key_ids          = [hcloud_ssh_key.admin.id]
  network_id           = module.networking.network_id
  private_ip           = var.ingress_edge_private_ip
  mgmt_subnet_cidr     = local.mgmt_subnet_cidr
  cdn_source_cidrs     = var.ingress_edge_cdn_source_cidrs
  labels               = local.common_labels
  cloud_init_user_data = templatefile("${path.module}/templates/ingress-edge-cloud-init.yaml.tpl", {})
}
