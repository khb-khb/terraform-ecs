variable "ecs_role_name" {
  type = string
}

variable "codedeploy_role_name" {
  type = string
}

variable "monitoring_chatbot_role_name" {
  type = string
}

variable "codedeploy_chatbot_role_name" {
  type = string
}

variable "web_task_role_name" {
  type = string
}

variable "db_secret_arn" {
  type = string
}

variable "api_task_role_name" {
  type = string
}

variable "api_s3_upload_policy_name" {
  type = string
}

variable "uploads_bucket_arn" {
  type = string
}

variable "admin_task_role_name" {
  type = string
}
