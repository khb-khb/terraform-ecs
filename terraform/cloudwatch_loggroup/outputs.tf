output "ecs_log_groups" {
  value = {
    for key, log_group in aws_cloudwatch_log_group.ecs_log_group :
    key => log_group.name
  }
}
