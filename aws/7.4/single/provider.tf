# Randomize string to avoid duplication
resource "random_string" "random_name_post" {
  length           = 3
  special          = true
  override_special = ""
  min_lower        = 3
}

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">= 2.0"
    }
  }
}

provider "aws" {
  region = var.region
  #access_key = var.access_key
  #secret_key = var.secret_key
}
