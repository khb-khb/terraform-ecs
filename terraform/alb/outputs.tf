output "blue_ecs_tg_arn" {
  value = aws_lb_target_group.blue_tg.arn
}

output "blue_ecs_tg_name" {
  value = aws_lb_target_group.blue_tg.name
}

output "green_ecs_tg_name" {
  value = aws_lb_target_group.green_tg.name
}

output "prod_listener_arn" {
  value = aws_lb_listener.prod_listener.arn
}

output "test_listener_arn" {
  value = aws_lb_listener.test_listener.arn
}

output "alb_name" {
  value = aws_lb.this.name
}

output "alb_arn_suffix" {
  value = aws_lb.this.arn_suffix
}

output "blue_tg_arn_suffix" {
  value = aws_lb_target_group.blue_tg.arn_suffix
}

output "green_tg_arn_suffix" {
  value = aws_lb_target_group.green_tg.arn_suffix
}
