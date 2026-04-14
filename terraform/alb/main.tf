resource "aws_lb" "this" {
  name               = var.lb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.alb_sg
  subnets            = var.subnets

  enable_deletion_protection = false

  tags = { Name = var.lb_name }

}

resource "aws_lb_target_group" "blue_tg" {
  name        = var.blue_tg_name
  port        = var.tg_port
  protocol    = var.tg_protocol
  target_type = "ip"
  vpc_id      = var.tg_vpc_id

  health_check {
    path                = var.health_check_path
    protocol            = var.tg_protocol
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = { Name = var.blue_tg_name }

}

resource "aws_lb_listener" "prod_listener" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.prod_listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue_tg.arn
  }
  lifecycle {
    ignore_changes = [
      default_action
    ]
  }
}


resource "aws_lb_target_group" "green_tg" {
  name        = var.green_tg_name
  port        = var.tg_port
  protocol    = var.tg_protocol
  target_type = "ip"
  vpc_id      = var.tg_vpc_id

  health_check {
    path                = var.health_check_path
    protocol            = var.tg_protocol
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = { Name = var.green_tg_name }

}

resource "aws_lb_listener" "test_listener" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.test_listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.green_tg.arn
  }

  lifecycle {
    ignore_changes = [
      default_action
    ]
  }
}
