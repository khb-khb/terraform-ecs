variable "aws_ecs_task_definitions" {
  type = map(object({
    ecs_family         = string
    execution_role_arn = string
    task_role_arn      = string
    task_cpu           = number
    task_mem           = number
    container_name     = string
    ecs_image          = string
    log_group_name     = string
    aws_region         = string
    container_port     = number
  }))
}

variable "aws_ecs_clusters" {
  type = map(string)
}

variable "aws_ecs_services" {
  type = map(object({
    ecs_service_name    = string
    cluster_key         = string
    task_definition_key = string
    desired_count       = number
    ecs_subnets         = list(string)
    security_groups     = list(string)
    target_group_arn    = string
    container_name      = string
    container_port      = number
  }))
}
