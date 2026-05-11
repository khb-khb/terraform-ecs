variable "db_subnet_group_name" {
  type = string
}

variable "db_subnet_ids" {
  type = list(string)
}

variable "db_identifier" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "db_security_group_ids" {
  type = list(string)
}

variable "backup_retention_period" {
  type = number
}

variable "skip_final_snapshot" {
  type = bool
}

variable "instance_class" {
  type = string
}

variable "engine" {
  type = string
}

variable "instance_count" {
  type    = number
  default = 1
}
