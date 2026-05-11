output "cloudfront_domain_names" {
  value = {
    assets  = aws_cloudfront_distribution.assets.domain_name
    uploads = aws_cloudfront_distribution.uploads.domain_name
  }
}

output "cloudfront_zone_ids" {
  value = {
    assets  = aws_cloudfront_distribution.assets.hosted_zone_id
    uploads = aws_cloudfront_distribution.uploads.hosted_zone_id
  }
}

output "cloudfront_arns" {
  value = {
    assets  = aws_cloudfront_distribution.assets.arn
    uploads = aws_cloudfront_distribution.uploads.arn
  }
}
