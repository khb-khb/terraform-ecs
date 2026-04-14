terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
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
}

module "vpc" {
  source = "./vpc"

  vpc_cidr_block     = var.vpc_cidr_block
  subnets            = var.subnets
  nat_gw_subnet_name = "public_subnet_2a"
}

module "alb" {
  source = "./alb"

  lb_name = "ecs-alb"
  alb_sg  = [module.security_group.alb_sg_id]
  subnets = module.vpc.public_subnet_ids

  blue_tg_name      = "blue-ecs-alb-tg-80"
  green_tg_name     = "green-ecs-alb-tg-80"
  tg_port           = 80
  tg_protocol       = "HTTP"
  tg_vpc_id         = module.vpc.vpc_id
  health_check_path = "/"

  prod_listener_port = 80
  test_listener_port = 8080
  listener_protocol  = "HTTP"
}

module "security_group" {
  source = "./security_group"

  vpc_id = module.vpc.vpc_id
  name   = "ecs_project"
}

module "ecr" {
  source = "./ecr"

  name = "front_ecr"
  tags = {
    Name = "front"
  }
}

module "iam_role" {
  source = "./iam_role"

  ecs_role_name                = "ecsTaskExecutionRole"
  codedeploy_role_name         = "codedeployRole"
  monitoring_chatbot_role_name = "monitoring_chatbotRole"
  codedeploy_chatbot_role_name = "codedeploy_chatbotRole"
}

module "ecs" {
  source             = "./ecs"
  execution_role_arn = module.iam_role.ecs_task_execution_role_arn
  ecs_image          = module.ecr.ecr_image_repo
  ecs_family         = "web_ecs"
  container_name     = "web_container"
  container_port     = 80
  ecs_cluster_name   = "web_ecs_cluster"
  ecs_service_name   = "web_ecs_service"
  ecs_subnets        = module.vpc.private_subnet_ids
  ecs_sg             = [module.security_group.ecs_sg_id]
  blue_ecs_tg_arn    = module.alb.blue_ecs_tg_arn
  depends_on         = [module.alb]
  log_group_name     = module.cloudwatch_log_group.ecs_log_group
  aws_region         = "us-west-2"
  desired_count      = 1
  task_cpu           = "256"
  task_mem           = "512"
}

module "codedeploy" {
  source              = "./codedeploy"
  codedeploy_name     = "ecs_codedeploy"
  group_name          = "codedeploy"
  ecs_cluster_name    = module.ecs.ecs_cluster_name
  ecs_service_name    = module.ecs.ecs_service_name
  blue_tg             = module.alb.blue_ecs_tg_name
  green_tg            = module.alb.green_ecs_tg_name
  prod_listener       = module.alb.prod_listener_arn
  test_listener       = module.alb.test_listener_arn
  codedeploy_iam_role = module.iam_role.codedeploy_role_arn
  #codedeploy_alarm        = module.cloudwatch_monitoring.codedeploy_alarm_names
}

module "autoscaling" {
  source = "./autoscaling"

  ecs_cluster_name = module.ecs.ecs_cluster_name
  ecs_service_name = module.ecs.ecs_service_name
  cpu_target_name  = "ecs-cpu-scaling"
  mem_target_name  = "ecs-memory-scaling"
}

module "cloudwatch_monitoring" {
  source = "./cloudwatch_monitoring"

  ecs_cluster_name              = module.ecs.ecs_cluster_name
  ecs_service_name              = module.ecs.ecs_service_name
  alb_name                      = module.alb.alb_name
  alb_arn_suffix                = module.alb.alb_arn_suffix
  blue_tg_name                  = module.alb.blue_ecs_tg_name
  green_tg_name                 = module.alb.green_ecs_tg_name
  blue_target_group_arn_suffix  = module.alb.blue_tg_arn_suffix
  green_target_group_arn_suffix = module.alb.green_tg_arn_suffix

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

  codedeploy_noti_rule_name = "codedeploy_noti_rule"
  codedeploy_ecs_group_arn  = module.codedeploy.codedeploy_ecs_group_arn

}

module "cloudwatch_log_group" {
  source = "./cloudwatch_loggroup"

  ecs_log_group_name           = "ecs_log_group"
  ecs_log_group_retention_days = 7
}
