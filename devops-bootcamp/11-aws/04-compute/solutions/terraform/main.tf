# Lab 4 — demo-app on EC2 behind an Application Load Balancer, in the VPC built by Module 03 (vpc_lab.sh):
#   internet → ALB (public subnets, sg alb) → Auto Scaling group 2-4 × t3.micro (private subnets, sg app)
# ☁️ Costs about $0.60/day (ALB + 2 instances) plus a NAT gateway for the private subnets. terraform destroy the same day!

data "aws_vpc" "lab" {
  tags = { project = "vpc-lab" }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.lab.id]
  }
  tags = { Name = "public-*" }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.lab.id]
  }
  tags = { Name = "private-*" }
}

data "aws_security_group" "alb" {
  vpc_id = data.aws_vpc.lab.id
  name   = "alb"
}

data "aws_security_group" "app" {
  vpc_id = data.aws_vpc.lab.id
  name   = "app"
}

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# The lab's alb security group allows 443 only; this listener uses plain HTTP on 80 for simplicity
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = data.aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_lb" "app" {
  name               = "demo-app"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.public.ids
  security_groups    = [data.aws_security_group.alb.id]
}

resource "aws_lb_target_group" "app" {
  name                 = "demo-app"
  port                 = 8000
  protocol             = "HTTP"
  vpc_id               = data.aws_vpc.lab.id
  deregistration_delay = 30

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_iam_role" "ec2" {
  name               = "demo-app-asg"
  assume_role_policy = file("${path.module}/../../../02-iam/solutions/policies/trust-ec2.json")
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "demo-app-asg"
  role = aws_iam_role.ec2.name
}

resource "aws_launch_template" "app" {
  name_prefix            = "demo-app-"
  image_id               = data.aws_ssm_parameter.al2023.value
  instance_type          = var.instance_type
  vpc_security_group_ids = [data.aws_security_group.app.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  metadata_options {
    http_tokens                 = "required" # IMDSv2 only
    http_put_response_hop_limit = 1
  }

  user_data = base64encode(join("\n", [
    "#!/bin/bash",
    "export APP_URL='${var.app_url}' APP_VERSION='${var.app_version}'",
    file("${path.module}/../user-data.sh"),
  ]))
}

resource "aws_autoscaling_group" "app" {
  name                      = "demo-app"
  min_size                  = 2
  max_size                  = 4
  desired_capacity          = 2
  vpc_zone_identifier       = data.aws_subnets.private.ids
  target_group_arns         = [aws_lb_target_group.app.arn]
  health_check_type         = "ELB" # replace instances the load balancer considers unhealthy
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.app.id
    version = aws_launch_template.app.latest_version
  }

  instance_refresh { # a new launch template version → rolling replacement, half at a time
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "demo-app"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu" {
  name                   = "cpu-50"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50
  }
}
