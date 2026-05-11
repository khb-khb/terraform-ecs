output "certificate_arn" {
  value = aws_acm_certificate_validation.main.certificate_arn
}

output "cdn_certificate_arn" {
  value = aws_acm_certificate_validation.cdn.certificate_arn
}
