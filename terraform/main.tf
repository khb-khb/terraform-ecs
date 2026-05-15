terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"

      configuration_aliases = [
        aws.oregon,
        aws.virginia
      ]
    }
  }
  # deploy 시 ecs task definition 에 필요한 값을 github actions 의 push-ecr.yml 에서
  # terraform output -raw 로 가져오기 위해 terrafrom state 를 s3 backend 로 관리한다.
  # github actions 는 로컬 pc 의 state 파일을 볼 수 없어서 github actions 과 aws 에 연결한 OIDC 를 통해 S3 에 접근하여 state 파일을 사용한다.
  backend "s3" {
    bucket       = "kim-terraform"
    key          = "aws_ecr/prod/terraform.tfstate"
    region       = "us-west-2"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-west-2"
  alias  = "oregon"
}

provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

module "vpc" {
  source = "./vpc"

  vpc_cidr_block     = var.vpc_cidr_block
  subnets            = var.subnets
  nat_gw_subnet_name = "public_subnet_2a"
}

module "alb" {
  source = "./alb"

  aws_lbs = {
    admin = {
      lb_name         = "admin-alb"
      security_groups = [module.security_group.alb_sg_ids["admin"]]
      subnets         = module.vpc.public_subnet_ids
      blue_tg_key     = "admin_blue"
      green_tg_key    = "admin_green"
    }
    web = {
      lb_name         = "web-alb"
      security_groups = [module.security_group.alb_sg_ids["web"]]
      subnets         = module.vpc.public_subnet_ids
      blue_tg_key     = "web_blue"
      green_tg_key    = "web_green"
    }
    api = {
      lb_name         = "api-alb"
      security_groups = [module.security_group.alb_sg_ids["api"]]
      subnets         = module.vpc.public_subnet_ids
      blue_tg_key     = "api_blue"
      green_tg_key    = "api_green"
    }
  }

  tg_vpc_id = module.vpc.vpc_id

  target_groups = {
    web_blue = {
      tg_name           = "web-blue"
      tg_port           = 80
      tg_protocol       = "HTTP"
      health_check_path = "/health"
    }
    web_green = {
      tg_name           = "web-green"
      tg_port           = 80
      tg_protocol       = "HTTP"
      health_check_path = "/health"
    }
    api_blue = {
      tg_name           = "api-blue"
      tg_port           = 3000
      tg_protocol       = "HTTP"
      health_check_path = "/api/health"
    }
    api_green = {
      tg_name           = "api-green"
      tg_port           = 3000
      tg_protocol       = "HTTP"
      health_check_path = "/api/health"
    }
    admin_blue = {
      tg_name           = "admin-blue"
      tg_port           = 80
      tg_protocol       = "HTTP"
      health_check_path = "/admin/health"
    }
    admin_green = {
      tg_name           = "admin-green"
      tg_port           = 80
      tg_protocol       = "HTTP"
      health_check_path = "/admin/health"
    }
  }

  http_port     = 80
  http_protocol = "HTTP"

  test_port     = 8080
  test_protocol = "HTTP"

  https_port     = 443
  https_protocol = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = module.acm.certificate_arn
}

module "security_group" {
  source = "./security_group"

  vpc_id = module.vpc.vpc_id
  alb_security_groups = [
    "web",
    "admin",
    "api"
  ]

  test_sg_cidr  = "175.195.248.198/32"
  db_sg_name    = "db_sg"
  web_sg_name   = "web_sg"
  api_sg_name   = "api_sg"
  admin_sg_name = "admin_sg"
}

module "ecr" {
  source = "./ecr"
  ecr_repos = {
    web   = "web"
    api   = "api"
    admin = "admin"
  }
}

module "iam_role" {
  source = "./iam_role"

  ecs_role_name                = "ecsTaskExecutionRole"
  codedeploy_role_name         = "codedeployRole"
  monitoring_chatbot_role_name = "monitoring_chatbotRole"
  codedeploy_chatbot_role_name = "codedeploy_chatbotRole"
  db_secret_arn                = module.secret_manager.db_secret_arn
  web_task_role_name           = "webTaskRole"
  api_task_role_name           = "apiTaskRole"
  admin_task_role_name         = "adminTaskRole"
  api_s3_upload_policy_name    = "api-s3-upload-policy"
  uploads_bucket_arn           = module.s3.bucket_arns["uploads"]
}

module "ecs" {
  source = "./ecs"

  aws_ecs_task_definitions = {
    web = {
      ecs_family         = "web-task"
      execution_role_arn = module.iam_role.ecs_task_execution_role_arn
      task_role_arn      = module.iam_role.web_task_role_arn
      task_cpu           = 256
      task_mem           = 512
      container_name     = "web_container"
      ecs_image          = "${module.ecr.ecr_image_repo_urls["web"]}:latest"
      log_group_name     = module.cloudwatch_log_group.ecs_log_groups["web"]
      aws_region         = "us-west-2"
      container_port     = 80
    }
    api = {
      ecs_family         = "api-task"
      execution_role_arn = module.iam_role.ecs_task_execution_role_arn
      task_role_arn      = module.iam_role.api_task_role_arn
      task_cpu           = 256
      task_mem           = 512
      container_name     = "api_container"
      ecs_image          = "${module.ecr.ecr_image_repo_urls["api"]}:latest"
      log_group_name     = module.cloudwatch_log_group.ecs_log_groups["api"]
      aws_region         = "us-west-2"
      container_port     = 3000
    }
    admin = {
      ecs_family         = "admin-task"
      execution_role_arn = module.iam_role.ecs_task_execution_role_arn
      task_role_arn      = module.iam_role.admin_task_role_arn
      task_cpu           = 256
      task_mem           = 512
      container_name     = "admin_container"
      ecs_image          = "${module.ecr.ecr_image_repo_urls["admin"]}:latest"
      log_group_name     = module.cloudwatch_log_group.ecs_log_groups["admin"]
      aws_region         = "us-west-2"
      container_port     = 80
    }
  }
  aws_ecs_clusters = {
    main = "web-cluster"
  }

  aws_ecs_services = {
    web = {
      ecs_service_name    = "web-service"
      desired_count       = 1
      ecs_subnets         = module.vpc.private_subnet_ids
      security_groups     = [module.security_group.web_sg_id]
      target_group_arn    = module.alb.target_group_arns["web_blue"]
      cluster_key         = "main"
      task_definition_key = "web"
      container_name      = "web_container"
      container_port      = 80
    }
    api = {
      ecs_service_name    = "api-service"
      desired_count       = 1
      ecs_subnets         = module.vpc.private_subnet_ids
      security_groups     = [module.security_group.api_sg_id]
      target_group_arn    = module.alb.target_group_arns["api_blue"]
      cluster_key         = "main"
      task_definition_key = "api"
      container_name      = "api_container"
      container_port      = 3000
    }
    admin = {
      ecs_service_name    = "admin-service"
      desired_count       = 1
      ecs_subnets         = module.vpc.private_subnet_ids
      security_groups     = [module.security_group.admin_sg_id]
      target_group_arn    = module.alb.target_group_arns["admin_blue"]
      cluster_key         = "main"
      task_definition_key = "admin"
      container_name      = "admin_container"
      container_port      = 80
    }
  }
}

module "codedeploy" {
  source = "./codedeploy"
  codedeploy_apps = [
    "web",
    "admin",
    "api"
  ]
  deployment_groups = {
    web = {
      deployment_group_name = "web_group"
      service_role_arn      = module.iam_role.codedeploy_role_arn
      cluster_name          = module.ecs.ecs_cluster_names["main"]
      apps_key              = "web"
      service_name          = module.ecs.ecs_service_names["web"]
      prod_listener_arn     = module.alb.https_listener_arns["web"]
      test_listener_arn     = module.alb.test_listener_arns["web"]
      prod_tg_name          = module.alb.target_group_names["web_blue"]
      test_tg_name          = module.alb.target_group_names["web_green"]
    }
    api = {
      deployment_group_name = "api_group"
      service_role_arn      = module.iam_role.codedeploy_role_arn
      cluster_name          = module.ecs.ecs_cluster_names["main"]
      apps_key              = "api"
      service_name          = module.ecs.ecs_service_names["api"]
      prod_listener_arn     = module.alb.https_listener_arns["api"]
      test_listener_arn     = module.alb.test_listener_arns["api"]
      prod_tg_name          = module.alb.target_group_names["api_blue"]
      test_tg_name          = module.alb.target_group_names["api_green"]
    }
    admin = {
      deployment_group_name = "admin_group"
      service_role_arn      = module.iam_role.codedeploy_role_arn
      cluster_name          = module.ecs.ecs_cluster_names["main"]
      apps_key              = "admin"
      service_name          = module.ecs.ecs_service_names["admin"]
      prod_listener_arn     = module.alb.https_listener_arns["admin"]
      test_listener_arn     = module.alb.test_listener_arns["admin"]
      prod_tg_name          = module.alb.target_group_names["admin_blue"]
      test_tg_name          = module.alb.target_group_names["admin_green"]
    }
  }
  codedeploy_alert = module.cloudwatch_monitoring.codedeploy_alert
}

module "autoscaling" {
  source = "./autoscaling"
  ecs_autoscaling_targets = {
    web = {
      ecs_cluster_name = module.ecs.ecs_cluster_names["main"]
      ecs_service_name = module.ecs.ecs_service_names["web"]
      min_capacity     = 1
      max_capacity     = 3
      cpu_target_value = 50
      mem_target_value = 60
    }
    admin = {
      ecs_cluster_name = module.ecs.ecs_cluster_names["main"]
      ecs_service_name = module.ecs.ecs_service_names["admin"]
      min_capacity     = 1
      max_capacity     = 3
      cpu_target_value = 50
      mem_target_value = 60
    }
    api = {
      ecs_cluster_name = module.ecs.ecs_cluster_names["main"]
      ecs_service_name = module.ecs.ecs_service_names["api"]
      min_capacity     = 1
      max_capacity     = 3
      cpu_target_value = 50
      mem_target_value = 60
    }
  }
}

module "cloudwatch_monitoring" {
  source = "./cloudwatch_monitoring"

  ecs_alarms = {
    web = {
      ecs_cluster_name = module.ecs.ecs_cluster_names["main"]
      ecs_service_name = module.ecs.ecs_service_names["web"]
    }
    admin = {
      ecs_cluster_name = module.ecs.ecs_cluster_names["main"]
      ecs_service_name = module.ecs.ecs_service_names["admin"]
    }
    api = {
      ecs_cluster_name = module.ecs.ecs_cluster_names["main"]
      ecs_service_name = module.ecs.ecs_service_names["api"]
    }
  }

  alb_alarms = {
    web   = module.alb.alb_arn_suffixes["web"]
    admin = module.alb.alb_arn_suffixes["admin"]
    api   = module.alb.alb_arn_suffixes["api"]
  }

  db_instance_identifier = module.rds.rds_instance_identifier

  alarm_actions = [module.sns.monitorig_sns_topic_arn]
}

module "sns" {
  source = "./sns"

  monitoring_alert_topic_name   = "monitoring_topic"
  monitoring_configuration_name = "monitoring_configure"
  monitoring_iam_role_arn       = module.iam_role.monitoring_chatbot_role_arn
  monitoring_slack_team_id      = "T0ARLK5TVKR"
  monitoring_slack_channel_id   = "C0ASF03VD89"

  codedeploy_topic_name         = "codedeploy_topic"
  codedeploy_configuration_name = "codedeploy_configure"
  codedeploy_iam_role_arn       = module.iam_role.codedeploy_chatbot_role_arn
  codedeploy_slack_team_id      = "T0ARLK5TVKR"
  codedeploy_slack_channel_id   = "C0AS4TVCYAZ"

  codedeploy_ecs_group_arns = {
    web   = module.codedeploy.codedeploy_ecs_group_arns["web"],
    admin = module.codedeploy.codedeploy_ecs_group_arns["admin"],
    api   = module.codedeploy.codedeploy_ecs_group_arns["api"]
  }
}

module "cloudwatch_log_group" {
  source = "./cloudwatch_loggroup"

  ecs_log_groups = {
    web = {
      log_group_name = "web"
      retention_days = 7
    }
    api = {
      log_group_name = "api"
      retention_days = 7
    }
    admin = {
      log_group_name = "admin"
      retention_days = 7
    }
  }
}

module "acm" {
  source = "./acm"

  providers = {
    aws.oregon   = aws.oregon
    aws.virginia = aws.virginia
  }

  # 내가 구입한 도메인명
  domain_name = "kim-test.shop"
  san_domain_name = [
    "www.kim-test.shop",
    "admin.kim-test.shop",
    "api.kim-test.shop"
  ]

  # assets - 공통 리소스 이미지/CSS 등 및 admin 리소스 (path 를 통해 cdn 분리) / uploads - 사용자 업로드
  cdn_domain_name = "assets.kim-test.shop"
  cdn_san_domain_name = [
    "uploads.kim-test.shop"
  ]
}

module "route53" {
  source = "./route53"

  domain_name = "kim-test.shop"

  alb_records = {
    root = {
      domain_name     = "kim-test.shop"
      alb_domain_name = module.alb.alb_dns_names["web"]
      alb_zone_id     = module.alb.alb_zone_ids["web"]
    }
    web = {
      domain_name     = "www.kim-test.shop"
      alb_domain_name = module.alb.alb_dns_names["web"]
      alb_zone_id     = module.alb.alb_zone_ids["web"]
    }
    api = {
      domain_name     = "api.kim-test.shop"
      alb_domain_name = module.alb.alb_dns_names["api"]
      alb_zone_id     = module.alb.alb_zone_ids["api"]
    }
    admin = {
      domain_name     = "admin.kim-test.shop"
      alb_domain_name = module.alb.alb_dns_names["admin"]
      alb_zone_id     = module.alb.alb_zone_ids["admin"]
    }
  }

  cdn_records = {
    assets = {
      domain_name            = "assets.kim-test.shop"
      cloudfront_domain_name = module.cloudfront.cloudfront_domain_names["assets"]
      cloudfront_zone_id     = module.cloudfront.cloudfront_zone_ids["assets"]
    }

    uploads = {
      domain_name            = "uploads.kim-test.shop"
      cloudfront_domain_name = module.cloudfront.cloudfront_domain_names["uploads"]
      cloudfront_zone_id     = module.cloudfront.cloudfront_zone_ids["uploads"]
    }
  }
}

module "secret_manager" {
  source = "./secrets_manager"

  db_secret_name = "db-credentials"
  db_username    = var.db_username
  db_password    = var.db_password
}

module "rds" {
  source = "./rds"

  db_subnet_group_name    = "db_subnet_group"
  db_subnet_ids           = module.vpc.db_subnet_ids
  db_identifier           = "web-db"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.04.0"
  instance_class          = "db.t3.medium"
  db_name                 = "web_db"
  db_username             = var.db_username
  db_password             = var.db_password
  db_security_group_ids   = [module.security_group.db_sg_id]
  db_port                 = 3306
  skip_final_snapshot     = true
  backup_retention_period = 7

}

module "s3" {
  source = "./s3"

  buckets = {
    uploads = "uploads-s3-kimhb",
    assets  = "assets-s3-kimhb"
  }
}

module "cloudfront" {
  source = "./cloudfront"

  assets_control_name                = "assets_control"
  assets_domain_name                 = "assets.kim-test.shop"
  assets_bucket_regional_domain_name = module.s3.bucket_regional_domain_names["assets"]
  assets_origin_id                   = "assets-origin"
  assets_bucket_id                   = module.s3.bucket_ids["assets"]
  assets_bucket_arn                  = module.s3.bucket_arns["assets"]

  uploads_control_name                = "uploads_control"
  uploads_domain_name                 = "uploads.kim-test.shop"
  uploads_bucket_regional_domain_name = module.s3.bucket_regional_domain_names["uploads"]
  uploads_origin_id                   = "uploads-origin"
  uploads_bucket_id                   = module.s3.bucket_ids["uploads"]
  uploads_bucket_arn                  = module.s3.bucket_arns["uploads"]

  acm_certificate_arn = module.acm.cdn_certificate_arn
}
