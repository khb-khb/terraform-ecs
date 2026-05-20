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

output "web_task_role_arn" {
  value = aws_iam_role.web_task_role.arn
}

output "api_task_role_arn" {
  value = aws_iam_role.api_task_role.arn
}

output "admin_task_role_arn" {
  value = aws_iam_role.admin_task_role.arn
}

output "bastion_iam_profile_name" {
  value = aws_iam_instance_profile.bastion_profile.name
}
