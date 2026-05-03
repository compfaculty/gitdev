output "public_ipv4" {
  value = hcloud_server.edge.ipv4_address
}

output "private_ipv4" {
  value = try(one([for n in hcloud_server.edge.network : n.ip]), null)
}

output "server_id" {
  value = hcloud_server.edge.id
}
