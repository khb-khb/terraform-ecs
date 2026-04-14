variable "monitoring_alert_topic_name" {
  type = string
}

variable "codedeploy_topic_name" {
  type = string
}

variable "monitoring_configuration_name" {
  type = string
}

variable "monitoring_iam_role_arn" {
  type = string
}

variable "monitoring_slack_team_id" {
  type = string
}

variable "monitoring_slack_channel_id" {
  type = string
}

variable "codedeploy_configuration_name" {
  type = string
}

variable "codedeploy_iam_role_arn" {
  type = string
}

variable "codedeploy_slack_team_id" {
  type = string
}

variable "codedeploy_slack_channel_id" {
  type = string
}

variable "codedeploy_noti_rule_name" {
  type = string
}

variable "codedeploy_ecs_group_arn" {
  type = string
}
