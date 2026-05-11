resource "aws_secretsmanager_secret" "db_secret" {
  name = var.db_secret_name
}

resource "aws_secretsmanager_secret_version" "db_secret" {
  secret_id = aws_secretsmanager_secret.db_secret.id

  secret_string = jsonencode({
    db_username = var.db_username
    db_password = var.db_password
  })
}
