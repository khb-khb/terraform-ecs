variable "codedeploy_name" {
  type = string
}

variable "group_name" {
  type = string
}

variable "codedeploy_iam_role" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_service_name" {
  type = string
}

variable "prod_listener" {
  type = string
}

variable "test_listener" {
  type = string
}

variable "blue_tg" {
  type = string
}

variable "green_tg" {
  type = string
}

# variable "codedeploy_alarm" {
#   type = list(string)
# }
