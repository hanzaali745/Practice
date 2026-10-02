variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "owner" {
  description = "Your name — added as a tag to everything"
  type        = string
  default     = "student"
}

variable "instance_type" {
  description = "Use a free-tier-eligible type for your account (check the EC2 console)"
  type        = string
  default     = "t3.micro"
}

variable "my_ip" {
  description = "Your public IP in CIDR form for SSH, e.g. 203.0.113.7/32 (curl https://checkip.amazonaws.com)"
  type        = string
  validation {
    condition     = can(cidrhost(var.my_ip, 0)) && var.my_ip != "0.0.0.0/0"
    error_message = "my_ip must be a CIDR like 203.0.113.7/32 — and never 0.0.0.0/0 for SSH."
  }
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}
