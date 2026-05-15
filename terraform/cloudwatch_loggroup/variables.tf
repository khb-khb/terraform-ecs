variable "ecs_log_groups" {
  type = map(object({
    log_group_name = string
    retention_days = number
  }))
}
