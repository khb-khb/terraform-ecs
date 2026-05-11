variable "ecs_autoscaling_targets" {
  type = map(object({
    max_capacity     = number
    min_capacity     = number
    ecs_cluster_name = string
    ecs_service_name = string
    mem_target_value = number
    cpu_target_value = number
  }))
}
