output "codedeploy_event_rule_name" {
  value = aws_cloudwatch_event_rule.codedeploy_state_change.name
}

output "codedeploy_event_rule_arn" {
  value = aws_cloudwatch_event_rule.codedeploy_state_change.arn
}
