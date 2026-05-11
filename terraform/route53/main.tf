data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

# 서비스 연결용
# alias A 레코드 생성, 도메인을 ALB 로 연결
# kim-test.shop, www.kim-test.shop 두 개 생성
resource "aws_route53_record" "alb_route53" {
  for_each = var.alb_records

  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.value.domain_name
  type    = "A"

  alias {
    name                   = each.value.alb_domain_name
    zone_id                = each.value.alb_zone_id
    evaluate_target_health = true
  }
}

#cdn
# cdn.kim-test.shop - CDN 연결
resource "aws_route53_record" "cdn_route53" {
  # 각각의 cloudfront 에 도메인을 넣기 때문에 variables.tf 에서 map 형식으로 받음
  for_each = var.cdn_records

  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.value.domain_name
  type    = "A"

  alias {
    name    = each.value.cloudfront_domain_name
    zone_id = each.value.cloudfront_zone_id
    # cdn 은 healthcheck 판단 불가 false
    evaluate_target_health = false
  }
}
