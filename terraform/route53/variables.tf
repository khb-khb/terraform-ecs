variable "domain_name" {
  type = string
}

variable "alb_records" {
  type = map(object({
    domain_name     = string
    alb_domain_name = string
    alb_zone_id     = string
  }))
}

variable "cdn_records" {
  type = map(object({
    domain_name            = string
    cloudfront_domain_name = string
    cloudfront_zone_id     = string
  }))
}
