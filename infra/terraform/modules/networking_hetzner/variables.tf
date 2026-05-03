variable "network_name" {
  description = "Name of the Hetzner private network"
  type        = string
}

variable "network_cidr" {
  description = "IPv4 range for the private network (RFC1918)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "mgmt_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "ci_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "network_zone" {
  description = "Hetzner network zone matching server location"
  type        = string
  default     = "eu-central"
}
