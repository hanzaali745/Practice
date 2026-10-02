output "public_ip" {
  value = aws_instance.web.public_ip
}

output "url" {
  value = "http://${aws_instance.web.public_ip}/"
}

output "ssh" {
  value = "ssh ubuntu@${aws_instance.web.public_ip}"
}

output "ami" {
  description = "Which Ubuntu image was chosen"
  value       = data.aws_ami.ubuntu.name
}
