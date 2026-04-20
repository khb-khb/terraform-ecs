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

resource "aws_lb_listener" "prod_listener_http" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.prod_listener_http_port
  protocol          = var.prod_listener_http_protocol

  default_action {
    type = "redirect"

    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
      host        = "#{host}"
      path        = "/#{path}"
      query       = "#{query}"
    }
  }
  lifecycle {
    ignore_changes = [
      default_action
    ]
  }
}

resource "aws_lb_listener" "prod_listener_https" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.prod_listener_https_port
  protocol          = var.prod_listener_https_protocol
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue_tg.arn
  }
  lifecycle {
    # apply(값 변경 상황) / destroy 시 리소스 삭제를 막기 때문에 apply 시에는 활성화, destroy 시에는 주석
    #prevent_destroy = true
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
  protocol          = var.test_listener_protocol

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
