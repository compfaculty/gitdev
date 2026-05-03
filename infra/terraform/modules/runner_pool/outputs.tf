output "runner_private_ips" {
  value = [for r in hcloud_server.runner : try(one([for n in r.network : n.ip]), null)]
}

output "runner_public_ips" {
  value = [for r in hcloud_server.runner : r.ipv4_address]
}

output "runner_ids" {
  value = [for r in hcloud_server.runner : r.id]
}
