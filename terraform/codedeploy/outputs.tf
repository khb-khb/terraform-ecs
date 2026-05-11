output "codedeploy_ecs_group_arns" {
  value = {
    for key, group in aws_codedeploy_deployment_group.ecs_group :
    key => group.arn
  }
}
