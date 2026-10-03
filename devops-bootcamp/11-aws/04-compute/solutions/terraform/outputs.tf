output "url" {
  value       = "http://${aws_lb.app.dns_name}"
  description = "curl it a few times: the message shows which instance answered"
}
