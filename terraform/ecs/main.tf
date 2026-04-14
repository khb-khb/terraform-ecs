resource "aws_ecs_task_definition" "this" {
  family                   = var.ecs_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role_arn

  cpu    = var.task_cpu
  memory = var.task_mem

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.ecs_image
      cpu       = tonumber(var.task_cpu)
      memory    = tonumber(var.task_mem)
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.log_group_name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_cluster" "this" {
  name = var.ecs_cluster_name

}

resource "aws_ecs_service" "this" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets          = var.ecs_subnets
    security_groups  = var.ecs_sg
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = var.blue_ecs_tg_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count,
      load_balancer
    ]
  }
}

