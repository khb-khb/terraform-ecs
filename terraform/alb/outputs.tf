output "https_listener_arns" {
  value = {
    for key, listener in aws_lb_listener.https :
    key => listener.arn
  }
}

output "test_listener_arns" {
  value = {
    for key, listener in aws_lb_listener.test :
    key => listener.arn
  }

}

output "target_group_arns" {
  value = {
    for key, tg in aws_lb_target_group.this :
    key => tg.arn
  }
}

output "target_group_names" {
  value = {
    for key, tg in aws_lb_target_group.this :
    key => tg.name
  }
}

output "target_group_suffixes" {
  value = {
    for key, tg in aws_lb_target_group.this :
    key => tg.arn_suffix
  }
}

output "alb_dns_names" {
  value = {
    for key, alb in aws_lb.this :
    key => alb.dns_name
  }
}

output "alb_zone_ids" {
  value = {
    for key, alb in aws_lb.this :
    key => alb.zone_id
  }
}

output "alb_arns" {
  value = {
    for key, alb in aws_lb.this :
    key => alb.arn
  }
}

output "alb_arn_suffixes" {
  value = {
    for key, alb in aws_lb.this :
    key => alb.arn_suffix
  }
}
