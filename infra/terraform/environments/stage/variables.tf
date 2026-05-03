variable "project_name" {
  type    = string
  default = "secure-redblue-stage"
}

variable "location" {
  type    = string
  default = "nbg1"
}

variable "network_zone" {
  type    = string
  default = "eu-central"
}

variable "ssh_public_key" {
  type        = string
  description = "Admin SSH public key — stage uses separate HCLOUD project + backend state recommended"
}

variable "vpn_ingress_allowlist" {
  type    = list(string)
  default = []
}

variable "ssh_bootstrap_allowlist" {
  type    = list(string)
  default = []
}

variable "gitlab_server_type" {
  type    = string
  default = "cx33"
}

variable "runner_count" {
  type    = number
  default = 1
}

variable "runner_server_type" {
  type    = string
  default = "cx22"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "enable_ingress_edge" {
  type    = bool
  default = false
}

variable "ingress_edge_cdn_source_cidrs" {
  type    = list(string)
  default = []
}

variable "ingress_edge_private_ip" {
  type    = string
  default = "10.10.1.90"
}

variable "ingress_edge_server_type" {
  type    = string
  default = "cx22"
}
