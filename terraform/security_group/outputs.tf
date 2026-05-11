output "alb_sg_ids" {
  value = {
    for key, sg in aws_security_group.alb_sg :
    key => sg.id
  }
}

output "ecs_sg_id" {
  value = aws_security_group.ecs_sg.id
}

output "db_sg_id" {
  value = aws_security_group.db_sg.id
}
