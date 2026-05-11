resource "aws_cloudwatch_log_group" "ecs_log_group" {
  for_each = var.ecs_log_groups

  name              = each.value.log_group_name
  retention_in_days = each.value.retention_days

  tags = {
    Name = each.value.log_group_name
  }

}
