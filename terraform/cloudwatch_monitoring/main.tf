resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  for_each = var.ecs_alarms

  alarm_name          = "${each.key}-cpu-high"
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
    ClusterName = each.value.ecs_cluster_name
    ServiceName = each.value.ecs_service_name
  }
  alarm_actions = var.alarm_actions
  ok_actions    = var.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  for_each = var.ecs_alarms

  alarm_name          = "${each.key}-memory-high"
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
    ClusterName = each.value.ecs_cluster_name
    ServiceName = each.value.ecs_service_name
  }
  alarm_actions = var.alarm_actions
  ok_actions    = var.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx_high" {
  for_each = var.alb_alarms

  alarm_name          = "${each.key}-alb-5xx"
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
    LoadBalancer = each.value
  }
  alarm_actions = var.alarm_actions
  ok_actions    = var.alarm_actions
}


# 추후 reader instancec 생성이 될 경우를 대비해 for_each 로 알람 구성
resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  for_each = var.db_instance_identifier

  alarm_name          = "${each.key}-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS CPU utilization is high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = each.key
  }
  alarm_actions = var.alarm_actions
  ok_actions    = var.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "rds_memory_high" {
  for_each = var.db_instance_identifier

  alarm_name          = "${each.key}-memory-high"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 3
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 536870912
  alarm_description   = "rds service memory high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = each.key
  }
  alarm_actions = var.alarm_actions
  ok_actions    = var.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "rds_connections_high" {
  for_each = var.db_instance_identifier

  alarm_name          = "${each.key}-connections-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 3
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 100
  alarm_description   = "rds service connections high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = each.key
  }
  alarm_actions = var.alarm_actions
  ok_actions    = var.alarm_actions
}
