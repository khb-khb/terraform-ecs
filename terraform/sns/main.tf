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

