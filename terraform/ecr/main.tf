resource "aws_ecr_repository" "this" {
  for_each = var.ecr_repos

  name                 = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = each.value
  }
}
