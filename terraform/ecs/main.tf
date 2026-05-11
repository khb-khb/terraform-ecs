resource "aws_ecs_task_definition" "this" {
  for_each = var.aws_ecs_task_definitions

  family                   = each.value.ecs_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = each.value.execution_role_arn
  task_role_arn            = each.value.task_role_arn
  cpu                      = each.value.task_cpu
  memory                   = each.value.task_mem

  container_definitions = jsonencode([
    {
      name      = each.value.container_name
      image     = each.value.ecs_image
      cpu       = each.value.task_cpu
      memory    = each.value.task_mem
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = each.value.log_group_name
          awslogs-region        = each.value.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
      portMappings = [
        {
          containerPort = each.value.container_port
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_cluster" "this" {
  for_each = var.aws_ecs_clusters

  name = each.value

}

resource "aws_ecs_service" "this" {
  for_each = var.aws_ecs_services

  name                   = each.value.ecs_service_name
  cluster                = aws_ecs_cluster.this[each.value.cluster_key].id
  task_definition        = aws_ecs_task_definition.this[each.value.task_definition_key].arn
  desired_count          = each.value.desired_count
  launch_type            = "FARGATE"
  enable_execute_command = true

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets          = each.value.ecs_subnets
    security_groups  = each.value.security_groups
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = each.value.target_group_arn
    container_name   = each.value.container_name
    container_port   = each.value.container_port
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count,
      load_balancer
    ]
  }
}

