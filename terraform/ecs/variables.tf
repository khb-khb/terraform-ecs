variable "execution_role_arn" {
  type = string
}

variable "ecs_image" {
  type = string
}

variable "ecs_family" {
  type = string
}

variable "container_name" {
  type = string
}

variable "container_port" {
  type = number
}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_service_name" {
  type = string
}

variable "ecs_subnets" {
  type = list(string)
}

variable "ecs_sg" {
  type = list(string)
}

variable "blue_ecs_tg_arn" {
  type = string
}

variable "log_group_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "desired_count" {
  type = number
}

variable "task_cpu" {
  type = string
}

variable "task_mem" {
  type = string
}
