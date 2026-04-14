output "ecs_service_name" {
  value = module.ecs.ecs_service_name
}

output "ecs_cluster_name" {
  value = module.ecs.ecs_cluster_name
}

output "ecs_log_group" {
  value = module.cloudwatch_log_group.ecs_log_group
}
