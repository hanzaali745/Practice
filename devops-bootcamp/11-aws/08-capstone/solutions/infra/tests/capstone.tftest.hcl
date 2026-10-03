# terraform test — checks the capstone's safety properties in seconds, offline: the AWS provider is MOCKED,
# so "apply" creates nothing anywhere (computed values like ARNs are made up). Run: terraform test

mock_provider "aws" {
  mock_data "aws_region" {
    defaults = { region = "eu-west-1" }
  }
  # the provider still validates ARN formats, so made-up values need to look like ARNs
  mock_resource "aws_iam_role" {
    defaults = { arn = "arn:aws:iam::123456789012:role/mock" }
  }
  mock_resource "aws_lb" {
    defaults = { arn = "arn:aws:elasticloadbalancing:eu-west-1:123456789012:loadbalancer/app/mock/0123456789abcdef", arn_suffix = "app/mock/0123456789abcdef" }
  }
  mock_resource "aws_lb_target_group" {
    defaults = { arn = "arn:aws:elasticloadbalancing:eu-west-1:123456789012:targetgroup/mock/0123456789abcdef", arn_suffix = "targetgroup/mock/0123456789abcdef" }
  }
  mock_resource "aws_sns_topic" {
    defaults = { arn = "arn:aws:sns:eu-west-1:123456789012:mock-alerts" }
  }
  mock_resource "aws_ecr_repository" {
    defaults = { arn = "arn:aws:ecr:eu-west-1:123456789012:repository/mock", repository_url = "123456789012.dkr.ecr.eu-west-1.amazonaws.com/mock" }
  }
  mock_resource "aws_iam_openid_connect_provider" {
    defaults = { arn = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com" }
  }
  mock_resource "aws_ecs_service" {
    defaults = { id = "arn:aws:ecs:eu-west-1:123456789012:service/mock/mock" }
  }
}

variables {
  image_tag   = "sha-test123"
  github_repo = "octo-org/demo-app"
}

run "production_defaults" {
  assert {
    condition     = aws_ecr_repository.app.image_tag_mutability == "IMMUTABLE" && aws_ecr_repository.app.image_scanning_configuration[0].scan_on_push
    error_message = "ECR tags must be immutable and scanned on push"
  }
  assert {
    condition     = output.nat_gateways == 1 && output.assign_public_ip == false
    error_message = "By default tasks run in private subnets behind a NAT gateway"
  }
  assert {
    condition     = alltrue([for a in aws_cloudwatch_metric_alarm.this : contains(a.alarm_actions, aws_sns_topic.alerts.arn) && strcontains(a.alarm_description, "Runbook:")])
    error_message = "Every alarm must notify SNS and link a runbook"
  }
  assert {
    condition     = length(aws_cloudwatch_metric_alarm.this) == 5
    error_message = "Expected the five symptom alarms"
  }
}

run "github_may_only_deploy_from_production" {
  assert {
    condition = (
      jsondecode(aws_iam_role.github_deploy.assume_role_policy).Statement[0].Condition.StringEquals["token.actions.githubusercontent.com:sub"]
      == "repo:octo-org/demo-app:environment:production"
    )
    error_message = "The deploy role must trust only the production environment of this repository"
  }
  assert {
    condition     = !strcontains(aws_iam_role_policy.github_deploy.policy, "\"ecs:*\"") && !strcontains(aws_iam_role_policy.github_deploy.policy, "\"Action\":\"*\"")
    error_message = "The deploy role must not get wildcard actions"
  }
}

run "lab_mode_without_nat" {
  variables {
    nat_gateway = false
  }
  assert {
    condition     = output.nat_gateways == 0 && output.assign_public_ip
    error_message = "Without NAT, tasks need public IPs (in public subnets) to pull images"
  }
}

run "existing_oidc_provider_is_reused" {
  variables {
    github_oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
  }
  assert {
    condition     = length(aws_iam_openid_connect_provider.github) == 0
    error_message = "Must not create a second GitHub OIDC provider"
  }
}

run "rejects_a_bad_repo_name" {
  command = plan
  variables {
    github_repo = "just-a-name"
  }
  expect_failures = [var.github_repo]
}

run "service_is_hardened" {
  module {
    source = "./modules/service"
  }
  variables {
    name             = "svc-test"
    vpc_id           = "vpc-123"
    alb_subnet_ids   = ["subnet-a", "subnet-b"]
    task_subnet_ids  = ["subnet-c", "subnet-d"]
    assign_public_ip = false
    image            = "123456789012.dkr.ecr.eu-west-1.amazonaws.com/svc:sha-1"
  }
  assert {
    condition     = jsondecode(aws_ecs_task_definition.app.container_definitions)[0].readonlyRootFilesystem && jsondecode(aws_ecs_task_definition.app.container_definitions)[0].user == "10001"
    error_message = "The container must run as non-root with a read-only root filesystem"
  }
  assert {
    condition     = aws_ecs_service.app.deployment_circuit_breaker[0].rollback
    error_message = "Failed deployments must roll back automatically"
  }
  assert {
    condition     = aws_vpc_security_group_ingress_rule.tasks_from_alb.referenced_security_group_id == aws_security_group.alb.id
    error_message = "Tasks must accept traffic only from the load balancer"
  }
}
