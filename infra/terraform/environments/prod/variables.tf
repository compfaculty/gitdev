variable "project_name" {
  type    = string
  default = "secure-redblue"
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
  description = "Your ed25519 or RSA public key string for Hetzner + cloud-init"
}

variable "vpn_ingress_allowlist" {
  type        = list(string)
  description = "CIDRs allowed to establish WireGuard to bastion (office / static IPs)"
  default     = []
}

variable "ssh_bootstrap_allowlist" {
  type        = list(string)
  description = "CIDRs for emergency SSH to bastion during bootstrap"
  default     = []
}

variable "gitlab_server_type" {
  type    = string
  default = "cpx51"
}

variable "runner_count" {
  type    = number
  default = 1
}

variable "runner_server_type" {
  type    = string
  default = "cx33"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "enable_ingress_edge" {
  type        = bool
  default     = false
  description = "Provision optional public edge VM (CDN allowlist). Do not point at GitLab UI; use for approved public shim only."
}

variable "ingress_edge_cdn_source_cidrs" {
  type        = list(string)
  default     = []
  description = "Inbound 80/443 sources (e.g. Cloudflare IP ranges). Empty + module uses 127.0.0.1 until you set real CIDRs."
}

variable "ingress_edge_private_ip" {
  type        = string
  default     = "10.0.1.90"
  description = "Private IP in mgmt subnet for edge reverse proxy"
}

variable "ingress_edge_server_type" {
  type    = string
  default = "cx23"
}
