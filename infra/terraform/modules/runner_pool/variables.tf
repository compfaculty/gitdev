variable "runner_count" {
  type        = number
  default     = 1
  description = "Number of GitLab Runner hosts in this tier"
}

variable "name_prefix" {
  type    = string
  default = "ci"
}

variable "tier" {
  type        = string
  description = "sensitivity tier: research|staging|restricted"
  default     = "restricted"
}

variable "server_image" {
  type    = string
  default = "ubuntu-24.04"
}

variable "server_type" {
  type    = string
  default = "cx33"
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

variable "mgmt_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "private_ips" {
  type        = list(string)
  default     = null
  description = "Static private IPs in ci subnet matching runner_count indices"
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "cloud_init_user_data" {
  type        = string
  default     = ""
  description = "#cloud-config for runner bootstrap"
}
