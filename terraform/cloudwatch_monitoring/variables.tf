variable "alarm_actions" {
  type = list(string)
}

variable "db_instance_identifier" {
  type = set(string)
}

variable "ecs_alarms" {
  type = map(object({
    ecs_cluster_name = string
    ecs_service_name = string
  }))
}

variable "alb_alarms" {
  type = map(string)
}
