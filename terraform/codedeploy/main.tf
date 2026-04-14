resource "aws_codedeploy_app" "ecs" {
  name             = var.codedeploy_name
  compute_platform = "ECS"

}

resource "aws_codedeploy_deployment_group" "ecs_group" {
  app_name              = aws_codedeploy_app.ecs.name
  deployment_group_name = var.group_name
  service_role_arn      = var.codedeploy_iam_role

  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  deployment_style {
    deployment_type   = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.prod_listener]
      }
      test_traffic_route {
        listener_arns = [var.test_listener]
      }
      target_group {
        name = var.blue_tg
      }
      target_group {
        name = var.green_tg
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

  #   alarm_configuration {
  #     alarms  = var.codedeploy_alarm
  #     enabled = true
  #   }
}
