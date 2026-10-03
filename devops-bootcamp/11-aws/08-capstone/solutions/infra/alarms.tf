# Alerting: symptoms users feel (errors, latency, capacity) → SNS → email (or Slack/PagerDuty via SNS subscriptions)

resource "aws_sns_topic" "alerts" {
  name = "${var.name}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.alert_email == "" ? 0 : 1
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# Count error log lines (demo-app LOG_FORMAT=json) as a metric
resource "aws_cloudwatch_log_metric_filter" "errors" {
  name           = "errors"
  log_group_name = module.service.log_group
  pattern        = "{ $.log.level = \"error\" }"
  metric_transformation {
    name          = "Errors"
    namespace     = var.name
    value         = "1"
    default_value = "0"
  }
}

locals {
  runbook = "https://github.com/${var.github_repo}/blob/main/docs/runbook.md"
  alb     = { LoadBalancer = module.service.alb_arn_suffix }
  alarms = {
    "5xx-errors" = {
      description = "The app returned 10+ 5xx responses in 5 minutes"
      namespace   = "AWS/ApplicationELB", metric = "HTTPCode_Target_5XX_Count", stat = "Sum"
      period      = 300, periods = 1, threshold = 10, comparison = "GreaterThanOrEqualToThreshold"
      dimensions  = local.alb
    }
    "slow-p99" = {
      description = "p99 response time above 1s for 3 minutes"
      namespace   = "AWS/ApplicationELB", metric = "TargetResponseTime", stat = "p99"
      period      = 60, periods = 3, threshold = 1, comparison = "GreaterThanThreshold"
      dimensions  = local.alb
    }
    "unhealthy-targets" = {
      description = "The load balancer sees unhealthy tasks for 3 minutes"
      namespace   = "AWS/ApplicationELB", metric = "UnHealthyHostCount", stat = "Maximum"
      period      = 60, periods = 3, threshold = 1, comparison = "GreaterThanOrEqualToThreshold"
      dimensions  = merge(local.alb, { TargetGroup = module.service.target_group_arn_suffix })
    }
    "too-few-tasks" = {
      description = "Fewer than 2 tasks running for 5 minutes: no redundancy left"
      namespace   = "ECS/ContainerInsights", metric = "RunningTaskCount", stat = "Minimum"
      period      = 60, periods = 5, threshold = 2, comparison = "LessThanThreshold"
      dimensions  = { ClusterName = module.service.cluster_name, ServiceName = module.service.service_name }
    }
    "error-logs" = {
      description = "20+ error log lines in 5 minutes"
      namespace   = var.name, metric = "Errors", stat = "Sum"
      period      = 300, periods = 1, threshold = 20, comparison = "GreaterThanOrEqualToThreshold"
      dimensions  = {}
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "this" {
  for_each            = var.alarms ? local.alarms : {}
  alarm_name          = "${var.name}-${each.key}"
  alarm_description   = "${each.value.description}. Runbook: ${local.runbook}"
  namespace           = each.value.namespace
  metric_name         = each.value.metric
  statistic           = startswith(each.value.stat, "p") ? null : each.value.stat
  extended_statistic  = startswith(each.value.stat, "p") ? each.value.stat : null
  period              = each.value.period
  evaluation_periods  = each.value.periods
  threshold           = each.value.threshold
  comparison_operator = each.value.comparison
  dimensions          = each.value.dimensions
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn] # say when it's over, too
}
