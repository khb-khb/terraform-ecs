output "ecs_service_names" {
  value = module.ecs.ecs_service_names
}

output "ecs_cluster_names" {
  value = module.ecs.ecs_cluster_names
}

output "ecs_log_groups" {
  value = module.cloudwatch_log_group.ecs_log_groups
}

output "rds_writer_endpoint" {
  value = module.rds.rds_writer_endpoint
}

output "db_secret_arn" {
  value = module.secret_manager.db_secret_arn
}

output "db_name" {
  value = module.rds.db_name
}

output "db_port" {
  value = module.rds.db_port
}

output "uploads_bucket_name" {
  value = module.s3.bucket_name["uploads"]
}

output "uploads_cdn_domain" {
  value = module.cloudfront.cloudfront_domain_names["uploads"]
}
