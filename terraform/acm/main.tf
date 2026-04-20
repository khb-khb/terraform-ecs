locals {
  subdomains = ["www", "app", "admin"]
  san_domains = [
    for sub in local.subdomains : "${sub}.${var.domain_name}"
  ]
}

# 콘솔 - route53 - 호스팅 영역 생성 후 NS 정보 (4건) 를 도메인을 구입한 가비아에 입력 (교체)
# 위 과정을 통해 도메인의 DNS 관리는 AWS (Route53) 로 변경
# 생성 된 Host Zone ID 를 data 로 불러와 사용
data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

# 인증서 요청
resource "aws_acm_certificate" "main" {
  domain_name = var.domain_name
  # 기본 도메인 + www 도메인 둘 다 처리, *.${var.domain_name} 도 가능하지만 정확한 도메인 관리를 위해 필요시마다 추가
  subject_alternative_names = local.san_domains
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# 위에서 생성한 ACM 인증서 DNS 검증
resource "aws_route53_record" "cert_validation" {
  # ACM 이 주는 정보들을 하나씩 반복 처리, 도메인이 여러 개이기 때문에 for_each 사용
  # ACM 정보 (list 형식이기 때문에 map 으로 변환)
  # domain_name = "kim-test.shop"
  # resource_record_name = "_xxxx.kim-test.shop"
  # resource_record_type = "CNAME"
  # resource_record_value = "_yyyy.acm-validations.aws"
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

# DNS 검증
# 위에서 생성한 Resource 레코드들을 가져와서 검증
resource "aws_acm_certificate_validation" "main" {
  certificate_arn = aws_acm_certificate.main.arn
  validation_record_fqdns = [
    for record in aws_route53_record.cert_validation : record.fqdn
  ]
}

# alias A 레코드 생성, 도메인을 ALB 로 연결
# kim-test.shop, www.kim-test.shop 두 개 생성
resource "aws_route53_record" "root" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "subdomains" {
  for_each = toset(local.subdomains)

  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${each.value}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
