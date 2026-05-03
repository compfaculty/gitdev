terraform {
  required_version = ">= 1.5.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.59"
    }
  }

  # backend "s3" {
  #   bucket = "your-terraform-state"
  #   key    = "secure-redblue/stage/terraform.tfstate"
  #   region = "eu-central-1"
  #   encrypt = true
  # }
}

provider "hcloud" {}
