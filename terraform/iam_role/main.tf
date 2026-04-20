# ecs_task_role
data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = var.ecs_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = {
    Name = var.ecs_role_name
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# codedeploy_role
data "aws_iam_policy_document" "codedeploy_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codedeploy_service_role" {
  name               = var.codedeploy_role_name
  assume_role_policy = data.aws_iam_policy_document.codedeploy_assume_role.json

  tags = {
    Name = var.codedeploy_role_name
  }
}

resource "aws_iam_role_policy_attachment" "codedeploy_role_policy" {
  role       = aws_iam_role.codedeploy_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

# monitoring_alert_chatbot role
data "aws_iam_policy_document" "chatbot_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["chatbot.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "monitoring_chatbot_service_role" {
  name               = var.monitoring_chatbot_role_name
  assume_role_policy = data.aws_iam_policy_document.chatbot_assume_role.json

  tags = {
    Name = var.monitoring_chatbot_role_name
  }
}

resource "aws_iam_role_policy_attachment" "chatbot_role_policy" {
  role       = aws_iam_role.monitoring_chatbot_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role" "codedeploy_chatbot_service_role" {
  name               = var.codedeploy_chatbot_role_name
  assume_role_policy = data.aws_iam_policy_document.chatbot_assume_role.json

  tags = {
    Name = var.codedeploy_chatbot_role_name
  }
}

resource "aws_iam_role_policy_attachment" "codedeploy_chatbot_role_policy" {
  role       = aws_iam_role.codedeploy_chatbot_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# ecs task role
resource "aws_iam_role" "ecs_task_role" {
  name               = var.ecs_task_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = {
    Name = var.ecs_task_role_name
  }
}

resource "aws_iam_role_policy" "ecs_task_exec_policy" {
  name = "ecs-task-exec-policy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      }
    ]
  })
}
