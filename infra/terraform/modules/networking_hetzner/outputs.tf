output "network_id" {
  value = hcloud_network.this.id
}

output "network_name" {
  value = hcloud_network.this.name
}

output "mgmt_subnet_id" {
  value = hcloud_network_subnet.mgmt.id
}

output "ci_subnet_id" {
  value = hcloud_network_subnet.ci.id
}
