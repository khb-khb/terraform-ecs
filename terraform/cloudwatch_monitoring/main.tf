resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "${var.ecs_service_name}-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "ECS service cpu high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
  alarm_actions = var.alarm_actions
  ok_actions    = var.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  alarm_name          = "${var.ecs_service_name}-memory-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 3
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "ECS service memory high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx_high" {
  alarm_name          = "${var.alb_name}-alb-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Target is returning 5XX responses"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.alarm_actions
}

# tg 를 health check 할 시 codedeploy 배포 할 때마다 prod listener 의 tg 가 변경되므로 배포마다 알람이 올 것이기 때문에 주석
# resource "aws_cloudwatch_metric_alarm" "blue_tg_healthy_host_low" {
#   alarm_name          = "${var.blue_tg_name}-tg-healthy-host-low"
#   comparison_operator = "LessThanThreshold"
#   evaluation_periods  = 2
#   datapoints_to_alarm = 2
#   metric_name         = "HealthyHostCount"
#   namespace           = "AWS/ApplicationELB"
#   period              = 60
#   statistic           = "Minimum"
#   threshold           = 1
#   alarm_description   = "Healthy host count is too low"
#   treat_missing_data  = "breaching"

#   dimensions = {
#     LoadBalancer = var.alb_arn_suffix
#     TargetGroup  = var.blue_target_group_arn_suffix
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "green_tg_healthy_host_low" {
#   alarm_name          = "${var.green_tg_name}-tg-healthy-host-low"
#   comparison_operator = "LessThanThreshold"
#   evaluation_periods  = 2
#   datapoints_to_alarm = 2
#   metric_name         = "HealthyHostCount"
#   namespace           = "AWS/ApplicationELB"
#   period              = 60
#   statistic           = "Minimum"
#   threshold           = 1
#   alarm_description   = "Healthy host count is too low"
#   treat_missing_data  = "breaching"

#   dimensions = {
#     LoadBalancer = var.alb_arn_suffix
#     TargetGroup  = var.green_target_group_arn_suffix
#   }
# }
