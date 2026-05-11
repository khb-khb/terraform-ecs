# ALB SG [admin, api, web]
resource "aws_security_group" "alb_sg" {
  for_each = var.alb_security_groups

  name   = "${each.key}-alb-sg"
  vpc_id = var.vpc_id
  tags = {
    Name = "${each.key}-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http_sg" {
  for_each = aws_security_group.alb_sg

  security_group_id = each.value.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https_sg" {
  for_each = aws_security_group.alb_sg

  security_group_id = each.value.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "alb_test_sg" {
  for_each = aws_security_group.alb_sg

  security_group_id = each.value.id
  cidr_ipv4         = var.test_sg_cidr
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_egress_sg" {
  for_each = aws_security_group.alb_sg

  security_group_id = each.value.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ECS SG
resource "aws_security_group" "ecs_sg" {
  name   = var.ecs_sg_name
  vpc_id = var.vpc_id
  tags = {
    Name = var.ecs_sg_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_ecs_ingress_sg" {
  for_each = aws_security_group.alb_sg

  security_group_id            = aws_security_group.ecs_sg.id
  referenced_security_group_id = each.value.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ecs_egress_sg" {
  security_group_id = aws_security_group.ecs_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# DB SG
resource "aws_security_group" "db_sg" {
  name   = var.db_sg_name
  vpc_id = var.vpc_id
  tags = {
    Name = var.db_sg_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_db_ingress_sg" {
  security_group_id            = aws_security_group.db_sg.id
  referenced_security_group_id = aws_security_group.ecs_sg.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "db_egress_sg" {
  security_group_id = aws_security_group.db_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
