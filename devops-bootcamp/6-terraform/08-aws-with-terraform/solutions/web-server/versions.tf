terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Lab 3: uncomment after creating the state bucket, then run: terraform init -migrate-state
  # backend "s3" {
  #   bucket       = "devops-bootcamp-tfstate-<your-account-id>"
  #   key          = "web-server/terraform.tfstate"
  #   region       = "eu-west-1"
  #   encrypt      = true
  #   use_lockfile = true
  # }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project   = "devops-bootcamp"
      ManagedBy = "terraform"
      Owner     = var.owner
    }
  }
}
