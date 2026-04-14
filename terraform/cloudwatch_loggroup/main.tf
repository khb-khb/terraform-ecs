resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = var.ecs_log_group_name
  retention_in_days = var.ecs_log_group_retention_days

  tags = {
    Name = var.ecs_log_group_name
  }

}
