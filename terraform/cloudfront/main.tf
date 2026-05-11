# assets cloudfront 생성
resource "aws_cloudfront_origin_access_control" "assets_control" {
  name                              = "${var.assets_control_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "assets" {
  aliases = [var.assets_domain_name]

  origin {
    domain_name              = var.assets_bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.assets_control.id
    origin_id                = var.assets_origin_id
  }

  enabled = true

  default_root_object = "index.html"

  # ordered_cache_behavior 를 통해 s3 내 디렉토리 경로 마다 서로 다른 캐시 정책 적용
  # admin 정적 리소스, 짧은 캐시
  ordered_cache_behavior {
    path_pattern           = "/admin/*"
    target_origin_id       = var.assets_origin_id
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true

    min_ttl     = 0
    default_ttl = 300
    max_ttl     = 3600

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  # www 정적 리소스, 긴 캐시
  ordered_cache_behavior {
    path_pattern           = "/www/*"
    target_origin_id       = var.assets_origin_id
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  default_cache_behavior {
    target_origin_id       = var.assets_origin_id
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    compress = true

    forwarded_values {
      # 쿼리스트링 무시로 캐시 효율 증가
      query_string = false

      # 쿠키 전달 none 으로 캐시 효율 증가
      cookies {
        forward = "none"
      }
    }
  }

  # 국가 제한 없음
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # acm 인증서 연결
  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

# assets s3 policy
resource "aws_s3_bucket_policy" "assets" {
  bucket = var.assets_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"

        Principal = {
          Service = "cloudfront.amazonaws.com"
        }

        Action   = "s3:GetObject"
        Resource = "${var.assets_bucket_arn}/*"

        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.assets.arn
          }
        }
      }
    ]
  })
}

# uploads cloudfront  생성
resource "aws_cloudfront_origin_access_control" "uploads_control" {
  name                              = "${var.uploads_control_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "uploads" {
  aliases = [var.uploads_domain_name]

  origin {
    domain_name              = var.uploads_bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.uploads_control.id
    origin_id                = var.uploads_origin_id
  }

  enabled = true

  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id       = var.uploads_origin_id
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    compress = true

    forwarded_values {
      # 쿼리스트링 무시로 캐시 효율 증가
      query_string = false

      # 쿠키 전달 none 으로 캐시 효율 증가
      cookies {
        forward = "none"
      }
    }
  }

  # 국가 제한 없음
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # acm 인증서 연결
  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

# uploads s3 policy
resource "aws_s3_bucket_policy" "uploads" {
  bucket = var.uploads_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"

        Principal = {
          Service = "cloudfront.amazonaws.com"
        }

        Action   = "s3:GetObject"
        Resource = "${var.uploads_bucket_arn}/*"

        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.uploads.arn
          }
        }
      }
    ]
  })
}
