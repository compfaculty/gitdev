variable "name" {
  type        = string
  description = "Hostname label (Hetzner server name)"
}

variable "server_image" {
  type    = string
  default = "ubuntu-24.04"
}

variable "server_type" {
  type    = string
  default = "cx23"
}

variable "location" {
  type = string
}

variable "ssh_key_ids" {
  type = list(string)
}

variable "network_id" {
  type = string
}

variable "private_ip" {
  type        = string
  description = "Static address in mgmt subnet (e.g. 10.0.1.90)"
}

variable "mgmt_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "cdn_source_cidrs" {
  type        = list(string)
  description = "Cloud CDN / WAF IPv4+IPv6 egress ranges — never leave empty in production"
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "cloud_init_user_data" {
  type    = string
  default = ""
}
