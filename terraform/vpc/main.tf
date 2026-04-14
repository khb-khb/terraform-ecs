locals {
  public_subnets = {
    for name, subnet in var.subnets : name => subnet
    if subnet.tier == "public"
  }

  private_subnets = {
    for name, subnet in var.subnets : name => subnet
    if subnet.tier == "private"
  }
  db_subnets = {
    for name, subnet in var.subnets : name => subnet
    if subnet.tier == "db"
  }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az

  tags = {
    Name = each.key
    Tier = each.value.tier
  }
}

# igw
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "main_igw"
  }
}

# nat_gw, in public_subnet_1
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.this[var.nat_gw_subnet_name].id

  tags = {
    Name = "nat_gw"
  }

  depends_on = [aws_internet_gateway.this]
}

# nat eip
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }
}

# public_route_table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = { Name = "public_route_table" }
}
# public_route_table 연결
resource "aws_route_table_association" "public_association" {
  for_each = local.public_subnets

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.public_route_table.id
}

# private_route_table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
  tags = { Name = "private_route_table" }
}
# private_route_table 연결
resource "aws_route_table_association" "private_association" {
  for_each = local.private_subnets

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.private_route_table.id
}

# db_route_table
resource "aws_route_table" "db_route_table" {
  vpc_id = aws_vpc.this.id

  tags = { Name = "db_route_table" }
}

# db_route_table 연결
resource "aws_route_table_association" "db_association" {
  for_each = local.db_subnets

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.db_route_table.id
}
