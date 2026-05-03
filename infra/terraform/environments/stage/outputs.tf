output "bastion_public_ipv4" {
  value       = module.bastion.public_ipv4
  description = "Stage WireGuard / SSH bastion endpoint"
}

output "gitlab_private_ipv4" {
  value       = module.gitlab_core.gitlab_private_ipv4
  description = "Stage GitLab private API/UI"
}

output "runner_private_ips" {
  value = module.runner_pool.runner_private_ips
}

output "ingress_edge_public_ipv4" {
  value       = var.enable_ingress_edge ? module.ingress_edge[0].public_ipv4 : null
  description = "Stage ingress edge when enabled"
}

output "ingress_edge_private_ipv4" {
  value = var.enable_ingress_edge ? module.ingress_edge[0].private_ipv4 : null
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
