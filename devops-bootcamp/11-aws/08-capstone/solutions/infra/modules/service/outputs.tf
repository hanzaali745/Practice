output "url" {
  value = "http://${aws_lb.this.dns_name}"
}

output "cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "service_name" {
  value = aws_ecs_service.app.name
}

output "service_arn" {
  value = aws_ecs_service.app.id
}

output "task_family" {
  value = aws_ecs_task_definition.app.family
}

output "role_arns" {
  value = [aws_iam_role.execution.arn, aws_iam_role.task.arn]
}

output "log_group" {
  value = aws_cloudwatch_log_group.app.name
}

output "alb_arn_suffix" {
  value = aws_lb.this.arn_suffix
}

output "target_group_arn_suffix" {
  value = aws_lb_target_group.app.arn_suffix
}
