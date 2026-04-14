output "ecr_image_repo" {
  value = "${aws_ecr_repository.this.repository_url}:latest"
}
