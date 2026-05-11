output "codedeploy_alert" {
  value = {
    for key, alert in aws_cloudwatch_metric_alarm.alb_5xx_high :
    key => alert.alarm_name
  }
}
