
variable "ecs_service_name" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "alarm_actions" {
  type = list(string)
}

variable "alb_name" {
  type = string
}

variable "alb_arn_suffix" {
  type = string
}

variable "blue_tg_name" {
  type = string
}

variable "green_tg_name" {
  type = string
}

variable "blue_target_group_arn_suffix" {
  type = string
}

variable "green_target_group_arn_suffix" {
  type = string
}
