variable "domain_name" {
  type = string
}

variable "san_domain_name" {
  type = list(string)
}

variable "cdn_domain_name" {
  type = string
}

variable "cdn_san_domain_name" {
  type = list(string)
}
