output "gitlab_private_ipv4" {
  value = try(one([for n in hcloud_server.gitlab.network : n.ip]), null)
}

output "gitlab_server_id" {
  value = hcloud_server.gitlab.id
}
