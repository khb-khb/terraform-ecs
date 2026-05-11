variable "tg_vpc_id" {
  type = string
}

variable "http_port" {
  type = number
}

variable "http_protocol" {
  type = string
}

variable "test_port" {
  type = number
}

variable "test_protocol" {
  type = string
}

variable "https_port" {
  type = number
}

variable "https_protocol" {
  type = string
}

variable "ssl_policy" {
  type = string
}

variable "certificate_arn" {
  type = string
}

variable "target_groups" {
  type = map(object({
    tg_name           = string
    tg_port           = number
    tg_protocol       = string
    health_check_path = string
  }))
}

variable "aws_lbs" {
  type = map(object({
    lb_name         = string
    security_groups = list(string)
    subnets         = list(string)
    blue_tg_key     = string
    green_tg_key    = string
  }))
}
