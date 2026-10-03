terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # ☁️ Real AWS: keep state in S3 (create the bucket once with ../bootstrap_state.sh), then terraform init -migrate-state
  # backend "s3" {
  #   bucket       = "tfstate-<account-id>-eu-west-1"
  #   key          = "demo-app/terraform.tfstate"
  #   region       = "eu-west-1"
  #   use_lockfile = true # S3-native state locking: no DynamoDB table needed any more
  #   encrypt      = true
  # }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = { project = var.name, managed-by = "terraform", repo = var.github_repo }
  }
}
