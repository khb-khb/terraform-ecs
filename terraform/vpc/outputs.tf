output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = [
    for name in keys(local.public_subnets) : aws_subnet.this[name].id
  ]
}

output "private_subnet_ids" {
  value = [
    for name in keys(local.private_subnets) : aws_subnet.this[name].id
  ]
}

output "db_subnet_ids" {
  value = [
    for name in keys(local.db_subnets) : aws_subnet.this[name].id
  ]
}
