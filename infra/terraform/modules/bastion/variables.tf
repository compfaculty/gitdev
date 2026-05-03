variable "instance_name" {
  type    = string
  default = "bastion-vpn"
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
  type    = string
  default = "nbg1"
}

variable "ssh_key_ids" {
  type        = list(string)
  description = "Hetzner SSH key resources registered in CLOUD_PROJECT"
}

variable "network_id" {
  type = string
}

variable "private_ip" {
  type        = string
  default     = null
  description = "Static private IP inside mgmt subnet; omit for dynamic"
}

variable "wireguard_port" {
  type    = number
  default = 51820
}

variable "vpn_ingress_allowlist" {
  type        = list(string)
  default     = []
  description = "CIDR list allowed to hit WireGuard; empty = restrictive placeholder (restricted in tfvars)"
}

variable "ssh_ingress_allowlist" {
  type        = list(string)
  default     = []
  description = "CIDR list for SSH during bootstrap only"
}

variable "ipv6_enabled" {
  type    = bool
  default = false
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "cloud_init_user_data" {
  type        = string
  default     = ""
  description = "#cloud-config snippets for nftables bootstrap (applied by Ansible for full baseline)"
}
