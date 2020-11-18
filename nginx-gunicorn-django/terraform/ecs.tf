##################################
# ECS Cluster
##################################
# ※ ECSクラスタ:
# Dockerコンテナを実行するホストサーバーを論理的に束ねるリソース

resource "aws_ecs_cluster" "main" {
  name = var.prefix
}

##################################
# Task Definition
##################################


resource "aws_ecs_task_definition" "main" {
  family                   = var.prefix
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions = templatefile(
    "./container_definitions.json",
    {
      container_name = var.container_name
      ecr_repository = "${aws_ecr_repository.webserver.repository_url}:${var.docker_image_tag}"
      region         = var.region
      postgres_host  = aws_db_instance.main.endpoint
      # postgres_user     = aws_db_instance.main.username
      # postgres_password = aws_db_instance.main.password
      # postgres_db       = aws_db_instance.main.name
    }
  )

  # Logging Docker to CloudWatch Logs
  execution_role_arn = module.ecs_task_execution_role.iam_role_arn
}

##################################
# ECS Service
##################################

resource "aws_ecs_service" "main" {
  name            = var.prefix
  cluster         = aws_ecs_cluster.main.arn
  task_definition = aws_ecs_task_definition.main.arn

  # 本番環境では2以上推奨
  #   1の場合、コンテナの異常終了時にESCサービスがタスクを再起動するまでアクセスできなくなるため
  desired_count = 2
  launch_type   = "FARGATE"

  # LATESTは最新バージョンとは限らないため、明示的に指定すること
  platform_version                  = "1.4.0"
  health_check_grace_period_seconds = 60

  network_configuration {
    assign_public_ip = true # public: true, private: false
    security_groups  = [module.webserver-sg.security_group_id]

    subnets = [
      aws_subnet.public_1a.id,
      aws_subnet.public_1c.id,
    ]
  }

  load_balancer {

    # コンテナ定義に複数のコンテナがある場合は、
    # 最初にロードバランサーからリクエストを受け取るコンテナの値を指定

    target_group_arn = aws_lb_target_group.main.arn
    container_name   = var.container_name # = container_definition.json:name
    container_port   = 80                 # = container_definition.json:portMappings.containerPort
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

##################################
# ECS Security Group
##################################

module "webserver-sg" {
  source      = "./modules/security_group"
  name        = "webserver-sg"
  vpc_id      = aws_vpc.main.id
  port        = 80
  cidr_blocks = [aws_vpc.main.cidr_block]
}
