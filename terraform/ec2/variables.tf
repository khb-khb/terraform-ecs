variable "ec2_ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "sg_id" {
  type = list(string)
}

variable "iam" {
  type = string
}

variable "ec2_name" {
  type = string
}

