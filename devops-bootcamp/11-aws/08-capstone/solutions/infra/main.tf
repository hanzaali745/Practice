# Phase 11 capstone — demo-app on AWS, built from everything in this phase:
#   ECR (images) · VPC (network module) · ECS Fargate + ALB (service module) · CloudWatch alarms → SNS (alarms.tf)
#   GitHub Actions deploys with OIDC — no stored AWS keys (github_oidc.tf)

resource "aws_ecr_repository" "app" {
  name                 = var.name
  image_tag_mutability = "IMMUTABLE" # a tag always means the same image: deploy and roll back by tag with confidence
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "KMS"
  }
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Untagged images go after 7 days"
        selection    = { tagStatus = "untagged", countType = "sinceImagePushed", countUnit = "days", countNumber = 7 }
        action       = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Keep the 30 newest releases (rollback history)"
        selection    = { tagStatus = "tagged", tagPrefixList = ["sha-"], countType = "imageCountMoreThan", countNumber = 30 }
        action       = { type = "expire" }
      },
    ]
  })
}

module "network" {
  source      = "./modules/network"
  name        = var.name
  azs         = var.azs
  nat_gateway = var.nat_gateway
}

module "service" {
  source           = "./modules/service"
  name             = var.name
  vpc_id           = module.network.vpc_id
  alb_subnet_ids   = module.network.public_subnet_ids
  task_subnet_ids  = var.nat_gateway ? module.network.private_subnet_ids : module.network.public_subnet_ids
  assign_public_ip = !var.nat_gateway
  image            = "${aws_ecr_repository.app.repository_url}:${var.image_tag}"
  environment      = { LOG_FORMAT = "json" }
  autoscaling      = var.autoscaling
}
