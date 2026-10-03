output "url" {
  value = module.service.url
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "logs" {
  value = "aws logs tail ${module.service.log_group} --follow"
}

output "github_variables" {
  description = "Repository variables for deploy-aws.yml (not secrets: none of these grant anything on their own)"
  value = {
    AWS_REGION     = var.region
    AWS_ROLE_ARN   = aws_iam_role.github_deploy.arn
    ECR_REPOSITORY = aws_ecr_repository.app.repository_url
    ECS_CLUSTER    = module.service.cluster_name
    ECS_SERVICE    = module.service.service_name
    TASK_FAMILY    = module.service.task_family
    APP_URL        = module.service.url
  }
}

output "assign_public_ip" {
  value = !var.nat_gateway
}

output "nat_gateways" {
  value = length(module.network.nat_gateway_ids)
}
