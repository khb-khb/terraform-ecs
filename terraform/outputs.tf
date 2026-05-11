output "ecs_service_names" {
  value = module.ecs.ecs_service_names
}

output "ecs_cluster_names" {
  value = module.ecs.ecs_cluster_names
}

output "ecs_log_group" {
  value = module.cloudwatch_log_group.ecs_log_group
}

output "rds_writer_endpoint" {
  value = module.rds.rds_writer_endpoint
}

output "db_secret_arn" {
  value = module.secret_manager.db_secret_arn
}
