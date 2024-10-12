resource "aws_ecs_cluster" "nestjs_main" {
  name = "${var.prefix}-nestjs-cluster"
}

resource "aws_ecs_task_definition" "nestjs_app" {
  family                   = "${var.prefix}-nestjs-app-task"
  execution_role_arn       = aws_iam_role.ecs_tasks_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions = templatefile("./templates/ecs/todo_app.json.tpl", {
    app_image           = var.nestjs_app_image
    app_port            = var.app_port
    fargate_cpu         = var.fargate_cpu
    fargate_memory      = var.fargate_memory
    aws_region          = var.aws_region
    DATABASE_HOST       = var.nestjs_db_endpoint
    DATABASE_PORT       = 3306
    DATABASE_NAME       = "demodb"
    DATABASE_USER       = "root"
    DATABASE_PASSWORD   = "TerraformRocksPa33W0rd!"  # In production, you should use secret manager to store the password
  })
  depends_on               = [aws_iam_role_policy_attachment.task_execution_role_policy_attachment]
}

resource "aws_ecs_service" "nestjs_main" {
  name            = "${var.prefix}-nestjs-service"
  cluster         = aws_ecs_cluster.nestjs_main.id
  task_definition = aws_ecs_task_definition.nestjs_app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = var.ecs_tasks_sg_ids
    subnets          = var.public_subnet_ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.nestjs_app.id
    container_name   = "todo-app" # Must match with the container name defined in template
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.nestjs_front_end, aws_iam_role_policy_attachment.task_execution_role_policy_attachment]
}




resource "aws_ecs_cluster" "springboot_main" {
  name = "${var.prefix}-springboot-cluster"
}

resource "aws_ecs_task_definition" "springboot_app" {
  family                   = "${var.prefix}-springboot-app-task"
  execution_role_arn       = aws_iam_role.ecs_tasks_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions = templatefile("./templates/ecs/todo_app.json.tpl", {
    app_image           = var.springboot_app_image
    app_port            = var.app_port
    fargate_cpu         = var.fargate_cpu
    fargate_memory      = var.fargate_memory
    aws_region          = var.aws_region
    DATABASE_HOST       = var.springboot_db_endpoint
    DATABASE_PORT       = 3306
    DATABASE_NAME       = "demodb"
    DATABASE_USER       = "root"
    DATABASE_PASSWORD   = "TerraformRocksPa33W0rd!"  # In production, you should use secret manager to store the password
  })
  depends_on               = [aws_iam_role_policy_attachment.task_execution_role_policy_attachment]
}

resource "aws_ecs_service" "springboot_main" {
  name            = "${var.prefix}-springboot-service"
  cluster         = aws_ecs_cluster.springboot_main.id
  task_definition = aws_ecs_task_definition.springboot_app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = var.ecs_tasks_sg_ids
    subnets          = var.public_subnet_ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.springboot_app.id
    container_name   = "todo-app" # Must match with the container name defined in template
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.springboot_front_end, aws_iam_role_policy_attachment.task_execution_role_policy_attachment]
}
