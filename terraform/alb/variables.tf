variable "lb_name" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "alb_sg" {
  type = list(string)
}

variable "blue_tg_name" {
  type = string
}

variable "tg_port" {
  type = number
}

variable "tg_protocol" {
  type = string
}

variable "tg_vpc_id" {
  type = string
}

variable "health_check_path" {
  type = string
}

variable "prod_listener_http_port" {
  type = number
}

variable "prod_listener_http_protocol" {
  type = string
}

variable "green_tg_name" {
  type = string
}

variable "test_listener_port" {
  type = number
}

variable "test_listener_protocol" {
  type = string
}

variable "prod_listener_https_port" {
  type = number
}

variable "prod_listener_https_protocol" {
  type = string
}

variable "ssl_policy" {
  type = string
}

variable "certificate_arn" {
  type = string
}
