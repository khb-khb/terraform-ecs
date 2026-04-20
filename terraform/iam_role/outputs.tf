output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "codedeploy_role_arn" {
  value = aws_iam_role.codedeploy_service_role.arn
}

output "monitoring_chatbot_role_arn" {
  value = aws_iam_role.monitoring_chatbot_service_role.arn
}

output "codedeploy_chatbot_role_arn" {
  value = aws_iam_role.codedeploy_chatbot_service_role.arn
}

output "ecs_task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}
