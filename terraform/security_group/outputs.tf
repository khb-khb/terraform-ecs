output "alb_sg_ids" {
  value = {
    for key, sg in aws_security_group.alb_sg :
    key => sg.id
  }
}

output "web_sg_id" {
  value = aws_security_group.web_sg.id
}

output "api_sg_id" {
  value = aws_security_group.api_sg.id
}

output "admin_sg_id" {
  value = aws_security_group.admin_sg.id
}

output "db_sg_id" {
  value = aws_security_group.db_sg.id
}
