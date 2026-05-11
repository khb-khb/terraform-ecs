resource "aws_lb" "this" {
  for_each = var.aws_lbs

  name               = each.value.lb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = each.value.security_groups
  subnets            = each.value.subnets

  enable_deletion_protection = false

  tags = { Name = each.value.lb_name }

}

resource "aws_lb_target_group" "this" {
  for_each = var.target_groups

  name        = each.value.tg_name
  port        = each.value.tg_port
  protocol    = each.value.tg_protocol
  target_type = "ip"
  vpc_id      = var.tg_vpc_id

  health_check {
    path                = each.value.health_check_path
    protocol            = each.value.tg_protocol
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = { Name = each.value.tg_name }
}

resource "aws_lb_listener" "http" {
  for_each = var.aws_lbs

  load_balancer_arn = aws_lb.this[each.key].arn
  port              = var.http_port
  protocol          = var.http_protocol

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

resource "aws_lb_listener" "https" {
  for_each = var.aws_lbs

  load_balancer_arn = aws_lb.this[each.key].arn
  port              = var.https_port
  protocol          = var.https_protocol
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.value.blue_tg_key].arn
  }
  lifecycle {
    # apply(값 변경 상황) / destroy 시 리소스 삭제를 막기 때문에 apply 시에는 활성화, destroy 시에는 주석
    #prevent_destroy = true
    ignore_changes = [
      default_action
    ]
  }
}

# 8080 port listener
resource "aws_lb_listener" "test" {
  for_each = var.aws_lbs

  load_balancer_arn = aws_lb.this[each.key].arn
  port              = var.test_port
  protocol          = var.test_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.value.green_tg_key].arn
  }

  lifecycle {
    ignore_changes = [
      default_action
    ]
  }
}
