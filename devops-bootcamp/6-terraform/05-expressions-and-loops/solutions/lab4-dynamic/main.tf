# Lab 4 — dynamic blocks. Validate-only: `terraform init && terraform validate` (no AWS account needed).
terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

variable "ingress_rules" {
  description = "Allowed inbound traffic"
  type = list(object({
    port        = number
    cidr        = string
    description = string
  }))
  default = [
    { port = 22, cidr = "10.0.0.0/8", description = "SSH from the VPN" },
    { port = 80, cidr = "0.0.0.0/0", description = "HTTP" },
    { port = 443, cidr = "0.0.0.0/0", description = "HTTPS" },
  ]
}

resource "aws_security_group" "web" {
  name        = "web"
  description = "Web servers"

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = [ingress.value.cidr]
    }
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
