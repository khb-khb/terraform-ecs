variable "ecs_log_groups" {
  type = mapobject({
    log_group_name = string
    retention_days = number
  })
}
