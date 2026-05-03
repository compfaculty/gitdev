output "public_ipv4" {
  value = hcloud_server.bastion.ipv4_address
}

output "private_ipv4" {
  # hcloud_server.network is a set (provider >= ~1.6x); derive single private IP deterministically.
  value = try(one([for n in hcloud_server.bastion.network : n.ip]), null)
}

output "server_id" {
  value = hcloud_server.bastion.id
}
