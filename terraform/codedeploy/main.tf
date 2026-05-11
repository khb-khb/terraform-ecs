resource "aws_codedeploy_app" "this" {
  for_each = var.codedeploy_apps

  name             = each.key
  compute_platform = "ECS"

}

resource "aws_codedeploy_deployment_group" "ecs_group" {
  for_each = var.deployment_groups

  app_name              = aws_codedeploy_app.this[each.value.apps_key].name
  deployment_group_name = each.value.deployment_group_name
  service_role_arn      = each.value.service_role_arn

  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  deployment_style {
    deployment_type   = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  ecs_service {
    cluster_name = each.value.cluster_name
    service_name = each.value.service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [each.value.prod_listener_arn]
      }
      test_traffic_route {
        listener_arns = [each.value.test_listener_arn]
      }
      target_group {
        name = each.value.prod_tg_name
      }
      target_group {
        name = each.value.test_tg_name
      }
    }
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  auto_rollback_configuration {
    enabled = true
    events = [
      "DEPLOYMENT_FAILURE",
      "DEPLOYMENT_STOP_ON_ALARM",
      "DEPLOYMENT_STOP_ON_REQUEST"
    ]
  }

  alarm_configuration {
    alarms  = var.codedeploy_alert
    enabled = true
  }
}
