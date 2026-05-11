variable "vpc_cidr_block" {
  type = string
}

variable "subnets" {
  type = map(object({
    cidr_block = string
    az         = string
    tier       = string
  }))
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}
