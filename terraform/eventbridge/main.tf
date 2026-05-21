resource "aws_cloudwatch_event_rule" "codedeploy_state_change" {
  name = var.rule_name

  event_pattern = jsonencode({
    source      = ["aws.codedeploy"]
    detail-type = ["CodeDeploy Deployment State-change Notification"]
    detail = {
      state = [
        "START",
        "SUCCESS",
        "FAILURE",
        "STOP",
        "STOPPED"
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "codedeploy_to_sns" {
  rule      = aws_cloudwatch_event_rule.codedeploy_state_change.name
  target_id = "codedeploy-sns"
  arn       = var.sns_topic_arn

  input_transformer {
    input_paths = {
      application = "$.detail.application"
      deployment  = "$.detail.deploymentId"
      state       = "$.detail.state"
      region      = "$.region"
      time        = "$.time"
    }

    input_template = <<EOF
{
  "version": "1.0",
  "source": "custom",
  "content": {
    "title": "CodeDeploy <state>",
    "description": "Application: <application>\nDeploymentId: <deployment>\nRegion: <region>\nTime: <time>"
  }
}
EOF
  }
}

resource "aws_sns_topic_policy" "allow_eventbridge_publish" {
  arn = var.sns_topic_arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEventBridgePublish"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = var.sns_topic_arn
      }
    ]
  })
}
