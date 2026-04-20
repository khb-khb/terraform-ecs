output "codedeploy_alert" {
  value = [
    aws_cloudwatch_metric_alarm.alb_5xx_high.alarm_name
  ]
}
