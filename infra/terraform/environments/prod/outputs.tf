output "bastion_public_ipv4" {
  value       = module.bastion.public_ipv4
  description = "Public IP for WireGuard endpoint (restrict via vpn_ingress_allowlist in production)"
}

output "gitlab_private_ipv4" {
  value       = module.gitlab_core.gitlab_private_ipv4
  description = "Reach GitLab HTTPS via VPN from this address"
}

output "runner_private_ips" {
  value = module.runner_pool.runner_private_ips
}

output "ingress_edge_public_ipv4" {
  value       = var.enable_ingress_edge ? module.ingress_edge[0].public_ipv4 : null
  description = "Public IP when enable_ingress_edge=true; front with CDN and lock down allowlist"
}

output "ingress_edge_private_ipv4" {
  value       = var.enable_ingress_edge ? module.ingress_edge[0].private_ipv4 : null
  description = "Upstream configuration for reverse proxy to internal service"
}

output "ansible_inventory_snippet" {
  value = <<-EOT
    [bastion]
    ${module.bastion.public_ipv4} ansible_user=root private_ip=${module.bastion.private_ipv4}

    [gitlab]
    ${module.gitlab_core.gitlab_private_ipv4} ansible_user=root private_ip=${module.gitlab_core.gitlab_private_ipv4}

    [runners]
    ${join("\n", [for ip in module.runner_pool.runner_private_ips : "${ip} ansible_user=root"])}
  EOT
}
