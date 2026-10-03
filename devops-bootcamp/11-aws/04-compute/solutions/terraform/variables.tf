variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "app_version" {
  type        = string
  default     = "1.0.0"
  description = "Changing it rolls out new instances (instance refresh)"
}

variable "app_url" {
  type        = string
  description = "Raw URL of app.py, e.g. https://raw.githubusercontent.com/<you>/Practice/master/devops-bootcamp/4-docker/app/app.py"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}
