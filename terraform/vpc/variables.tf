variable "vpc_cidr_block" {
    type = string
}

variable "subnets" {
    type = map(object({
      cidr_block = string
      az = string
      tier = string
    }))
}

variable "nat_gw_subnet_name" {
    type = string
}