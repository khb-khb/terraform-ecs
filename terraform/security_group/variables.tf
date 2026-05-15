variable "vpc_id" {
  type = string
}

variable "alb_security_groups" {
  type = set(string)
}

variable "test_sg_cidr" {
  type = string
}


variable "web_sg_name" {
  type = string
}

variable "db_sg_name" {
  type = string
}

variable "api_sg_name" {
  type = string
}

variable "admin_sg_name" {
  type = string
}
