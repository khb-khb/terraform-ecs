variable "codedeploy_alert" {
  type = list(string)
}

variable "codedeploy_apps" {
  type = set(string)
}

variable "deployment_groups" {
  type = map(object({
    deployment_group_name = string
    apps_key              = string
    service_role_arn      = string
    cluster_name          = string
    service_name          = string
    prod_listener_arn     = string
    test_listener_arn     = string
    prod_tg_name          = string
    test_tg_name          = string
  }))
}
