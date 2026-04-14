resource "aws_sns_topic" "monitoring_alert" {
  name = var.monitoring_alert_topic_name
}

resource "aws_sns_topic" "deploy_alert" {
  name = var.codedeploy_topic_name
}

resource "aws_chatbot_slack_channel_configuration" "monitoring_configure" {
  configuration_name = var.monitoring_configuration_name
  iam_role_arn       = var.monitoring_iam_role_arn
  sns_topic_arns     = [aws_sns_topic.monitoring_alert.arn]
  slack_team_id      = var.monitoring_slack_team_id
  slack_channel_id   = var.monitoring_slack_channel_id
  logging_level      = "ERROR"

  tags = {
    Name = var.monitoring_configuration_name
  }
}

resource "aws_chatbot_slack_channel_configuration" "codedeploy_configure" {
  configuration_name = var.codedeploy_configuration_name
  iam_role_arn       = var.codedeploy_iam_role_arn
  sns_topic_arns     = [aws_sns_topic.deploy_alert.arn]
  slack_team_id      = var.codedeploy_slack_team_id
  slack_channel_id   = var.codedeploy_slack_channel_id
  logging_level      = "INFO"

  tags = {
    Name = var.codedeploy_configuration_name
  }
}


# codedeploy_alert use codestar
data "aws_iam_policy_document" "codestar_noti_to_sns" {
  statement {
    effect = "Allow"

    actions = ["sns:Publish"]

    principals {
      type        = "Service"
      identifiers = ["codestar-notifications.amazonaws.com"]
    }

    resources = [aws_sns_topic.deploy_alert.arn]
  }
}

resource "aws_sns_topic_policy" "codedeploy_noti" {
  arn    = aws_sns_topic.deploy_alert.arn
  policy = data.aws_iam_policy_document.codestar_noti_to_sns.json
}

resource "aws_codestarnotifications_notification_rule" "codedeploy_noti_rule" {
  name        = var.codedeploy_noti_rule_name
  detail_type = "FULL"
  resource    = var.codedeploy_ecs_group_arn
  status      = "ENABLED"
  event_type_ids = [
    "codedeploy-application-deployment-started",
    "codedeploy-application-deployment-succeeded",
    "codedeploy-application-deployment-failed"
  ]

  target {
    type    = "SNS"
    address = aws_sns_topic.deploy_alert.arn
  }

  depends_on = [
    aws_sns_topic_policy.codedeploy_noti
  ]
}
