terraform {
  required_version = ">= 1.5.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.59"
    }
  }

  # Uncomment for remote state (S3-compatible or Terraform Cloud)
  # backend "s3" {
  #   bucket = "your-terraform-state"
  #   key    = "secure-redblue/prod/terraform.tfstate"
  #   region = "eu-central-1"
  #   encrypt = true
  # }
}

provider "hcloud" {
  # token: export HCLOUD_TOKEN in environment (never commit)
}
