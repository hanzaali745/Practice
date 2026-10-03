output "url" {
  value = "http://${aws_lb.app.dns_name}"
}

output "logs" {
  value = "aws logs tail ${aws_cloudwatch_log_group.app.name} --follow"
}
