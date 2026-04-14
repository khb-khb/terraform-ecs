output "codedeploy_alarm_names" {
  value = [
    aws_cloudwatch_metric_alarm.alb_5xx_high.alarm_name,
    aws_cloudwatch_metric_alarm.green_tg_healthy_host_low.alarm_name
  ]
}
