output "monitoring_sns_topic_arn" {
  value = aws_sns_topic.monitoring_alert.arn
}

output "deploy_topic_arn" {
  value = aws_sns_topic.deploy_alert.arn
}
