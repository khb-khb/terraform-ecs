output "ecs_service_names" {
  value = {
    for key, service in aws_ecs_service.this :
    key => service.name
  }
}

output "ecs_cluster_names" {
  value = {
    for key, cluster in aws_ecs_cluster.this :
    key => cluster.name
  }
}
