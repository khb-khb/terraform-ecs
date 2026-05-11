# 콘솔 - route53 - 호스팅 영역 생성 후 NS 정보 (4건) 를 도메인을 구입한 가비아에 입력 (교체)
# 위 과정을 통해 도메인의 DNS 관리는 AWS (Route53) 로 변경
# 생성 된 Host Zone ID 를 data 로 불러와 사용
data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

# ALB용 인증서 요청
resource "aws_acm_certificate" "main" {
  provider = aws.oregon

  domain_name = var.domain_name
  # 기본 도메인 + www 도메인 둘 다 처리, *.${var.domain_name} 도 가능하지만 정확한 도메인 관리를 위해 필요시마다 추가
  # san 방식으로 한 인증서에 여러 도메인을 넣는 방식
  subject_alternative_names = var.san_domain_name
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# ALB용 ACM 인증서 DNS 검증 CNAME 레코드 생성
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

# ALB용 ACM 인증서 검증 완료 대기
resource "aws_acm_certificate_validation" "main" {
  provider = aws.oregon

  certificate_arn = aws_acm_certificate.main.arn
  validation_record_fqdns = [
    for record in aws_route53_record.cert_validation : record.fqdn
  ]
}


# cdn 도메인, san 방식
# ACM 인증서 요청
resource "aws_acm_certificate" "cdn" {
  provider = aws.virginia

  domain_name = var.cdn_domain_name

  subject_alternative_names = var.cdn_san_domain_name

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# CloudFront용 ACM 인증서 DNS 검증 CNAME 레코드 생성
resource "aws_route53_record" "cdn_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cdn.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

# CloudFront용 ACM 인증서 검증 완료 대기
resource "aws_acm_certificate_validation" "cdn" {
  provider = aws.virginia

  certificate_arn = aws_acm_certificate.cdn.arn

  validation_record_fqdns = [
    for record in aws_route53_record.cdn_cert_validation : record.fqdn
  ]
}
