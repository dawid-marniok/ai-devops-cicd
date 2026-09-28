terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80"
    }
  }
}

provider "aws" {
  region  = "eu-central-1"
  profile = "terraform-szkolenie"
}

module "app_storage" {
  source = "../../modules/app-storage"

  uczestnik = "prowadzacy"
  blok      = "b1"
}

output "test_outputs" {
  value = module.app_storage
}
