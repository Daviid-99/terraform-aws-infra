############################################
# Data sources: using your existing AWS infra
############################################
data "aws_vpc" "main" {
  id = "vpc-0a7351e195d23740a"
}

data "aws_subnet" "public_subnet_a" {
  id = "subnet-0052a1dc2bc8961c7"
}

data "aws_security_group" "ecs_service_sg" {
  id = "sg-0ac2c3e2be8708697"
}

############################################
# ECR Repository
############################################
resource "aws_ecr_repository" "ecs_repo" {
  name = "terraform-ecs-app"
}

############################################
# ECS Cluster
############################################
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster"
}

############################################
# Task Definition
############################################
resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn # <- defined in iam.tf

  container_definitions = jsonencode([
    {
      name      = "ecs-app"
      image     = "${aws_ecr_repository.ecs_repo.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
    }
  ])
}

############################################
# ECS Service (connects to existing ALB)
############################################
resource "aws_ecs_service" "ecs_service" {
  name            = "ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [data.aws_subnet.public_subnet_a.id]
    security_groups  = [data.aws_security_group.ecs_service_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn   # <- defined in alb.tf
    container_name   = "ecs-app"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.ecs_listener] # <- defined in alb.tf
}
