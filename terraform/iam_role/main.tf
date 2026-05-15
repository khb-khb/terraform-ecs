# ecs_task_role - ecs 가 컨테이너를 실행할 때 사용하는 역할 // 이미지 pull, 로그, secret 등 사용
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

# 이미 존재하는 정책을 사용할 경우 attachment
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# 인라인 정책을 직접 생성해서 사용할 경우
resource "aws_iam_role_policy" "ecs_execution_secrets_policy" {
  name = "ecs-execution-secrets-policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.db_secret_arn
      }
    ]
  })
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

# ecs task role - 컨테이너 (앱) 가 실행 중 사용하는 역할 // s3, sqs, sns 등 서비스 사용

# web task role
resource "aws_iam_role" "web_task_role" {
  name               = var.web_task_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = {
    Name = var.web_task_role_name
  }
}
resource "aws_iam_role_policy" "web_task_exec_policy" {
  name = var.web_task_role_name
  role = aws_iam_role.web_task_role.id

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

# api task role
resource "aws_iam_role" "api_task_role" {
  name               = var.api_task_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = {
    Name = var.api_task_role_name
  }
}
resource "aws_iam_role_policy" "api_task_exec_policy" {
  name = var.api_task_role_name
  role = aws_iam_role.api_task_role.id

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

resource "aws_iam_role_policy" "api_s3_upload_policy" {
  name = var.api_s3_upload_policy_name
  role = aws_iam_role.api_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${var.uploads_bucket_arn}/*"
      }
    ]
  })
}

# admin task role
resource "aws_iam_role" "admin_task_role" {
  name               = var.admin_task_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = {
    Name = var.admin_task_role_name
  }
}
resource "aws_iam_role_policy" "admin_task_exec_policy" {
  name = var.admin_task_role_name
  role = aws_iam_role.admin_task_role.id

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
