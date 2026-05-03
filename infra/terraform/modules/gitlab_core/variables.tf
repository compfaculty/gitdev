variable "instance_name" {
  type    = string
  default = "gitlab-core"
}

variable "server_image" {
  type    = string
  default = "ubuntu-24.04"
}

variable "server_type" {
  description = "Use >= 16GB RAM for production Omnibus recommendation"
  type        = string
  default     = "cpx51"
}

variable "location" {
  type    = string
  default = "nbg1"
}

variable "ssh_key_ids" {
  type = list(string)
}

variable "network_id" {
  type = string
}

variable "private_ip" {
  type    = string
  default = "10.0.1.10"
}

variable "mgmt_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "ci_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "additional_gitlab_https_sources" {
  type        = list(string)
  default     = []
  description = "Optional bastion egress IP mapped into VPN NAT if needed"
}

variable "enable_gitlab_ssh" {
  type    = bool
  default = true
}

variable "public_ipv4_enabled" {
  type        = bool
  default     = false
  description = "Keep false so GitLab is not internet-reachable directly"
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "cloud_init_user_data" {
  type    = string
  default = ""
}
