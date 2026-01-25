resource "aws_ecs_cluster" "example" {
  name = "${var.env}-example-cluster"
}

resource "aws_ecs_task_definition" "example" {
  family                   = "example-task"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.env}-example-container"
      image     = "nginx:latest" # ${aws_ecr_repository.example.repository_url}:v1.0"
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = "ap-northeast-1"
          awslogs-stream-prefix = "example"
          awslogs-group         = "/${var.env}-ecs/example"
        }
      }
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "example" {
  name            = "${var.env}-example-service"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.example.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = false
    subnets          = values(aws_subnet.private)[*].id
    security_groups  = [aws_security_group.nginx.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.example.arn
    container_name   = "${var.env}-example-container"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.https]

  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_security_group" "nginx" {
  name        = "${var.env}-nginx"
  description = "nginx"
  vpc_id      = aws_vpc.example.id

  tags = {
    Name = "${var.env}-nginx"
  }
}

resource "aws_vpc_security_group_ingress_rule" "nginx" {
  security_group_id            = aws_security_group.nginx.id
  referenced_security_group_id = aws_security_group.https.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "nginx" {
  security_group_id = aws_security_group.nginx.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_cloudwatch_log_group" "example" {
  name              = "/${var.env}-ecs/example"
  retention_in_days = 7
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.env}-ecs-task-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_execution_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "ecs_task_execution" {
  name   = "${var.env}-ecs-task-execution"
  policy = data.aws_iam_policy_document.ecs_task_execution.json
}

data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_execution" {
  source_policy_documents = [data.aws_iam_policy.ecs_task_execution_role_policy.policy]

  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters", "kms:Decrypt"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution.arn
}
