# Lab 3 — demo-app on ECS Fargate (serverless containers) behind an ALB, in the Module 03 VPC:
#   internet → ALB (public subnets) → ECS service: 2-6 Fargate tasks (private subnets) → logs in CloudWatch
# ☁️ ~$1/day (ALB + 2 × 0.25 vCPU tasks) + NAT gateway (or VPC endpoints for ECR/logs). terraform destroy the same day!

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

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = data.aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/demo-app"
  retention_in_days = 14 # logs that never expire are a slow-growing bill
}

resource "aws_ecs_cluster" "main" {
  name = "demo"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Two roles: the EXECUTION role is used by ECS itself (pull the image, write logs);
# the TASK role is what YOUR code gets (here: nothing yet — add S3/DynamoDB permissions as the app needs them)
data "aws_iam_policy_document" "ecs_tasks" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution" {
  name               = "demo-app-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks.json
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
  name               = "demo-app-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks.json
}

resource "aws_ecs_task_definition" "app" {
  family                   = "demo-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc" # every task gets its own network interface and security group
  cpu                      = 256      # 0.25 vCPU
  memory                   = 512
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([{
    name         = "app"
    image        = var.image
    essential    = true
    portMappings = [{ containerPort = 8000, protocol = "tcp" }]
    environment = [
      { name = "APP_VERSION", value = var.app_version },
      { name = "LOG_FORMAT", value = "json" },
    ]
    readonlyRootFilesystem = true
    user                   = "10001"
    healthCheck = {
      command  = ["CMD", "python3", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8000/health', timeout=2)"]
      interval = 15
      retries  = 3
    }
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.app.name
        awslogs-region        = var.region
        awslogs-stream-prefix = "app"
      }
    }
  }])
}

resource "aws_lb" "app" {
  name               = "demo-ecs"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.public.ids
  security_groups    = [data.aws_security_group.alb.id]
}

resource "aws_lb_target_group" "app" {
  name                 = "demo-ecs"
  port                 = 8000
  protocol             = "HTTP"
  target_type          = "ip" # Fargate tasks are registered by IP
  vpc_id               = data.aws_vpc.lab.id
  deregistration_delay = 30
  health_check {
    path     = "/health"
    interval = 10
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

resource "aws_ecs_service" "app" {
  name            = "demo-app"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.private.ids
    security_groups  = [data.aws_security_group.app.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = 8000
  }

  deployment_minimum_healthy_percent = 100 # rolling deploy: start new tasks before stopping old ones
  deployment_maximum_percent         = 200
  deployment_circuit_breaker { # a release that never gets healthy is rolled back automatically
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [desired_count] # autoscaling owns the count after creation
  }

  depends_on = [aws_lb_listener.http]
}

# Scale on CPU between 2 and 6 tasks. (Local AWS: moto never finishes creating scaling targets — use -var autoscaling=false)
resource "aws_appautoscaling_target" "app" {
  count              = var.autoscaling ? 1 : 0
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 2
  max_capacity       = 6
}

resource "aws_appautoscaling_policy" "cpu" {
  count              = var.autoscaling ? 1 : 0
  name               = "cpu-60"
  service_namespace  = aws_appautoscaling_target.app[0].service_namespace
  resource_id        = aws_appautoscaling_target.app[0].resource_id
  scalable_dimension = aws_appautoscaling_target.app[0].scalable_dimension
  policy_type        = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 60
  }
}
