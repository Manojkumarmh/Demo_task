# VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "ecs_vpc"
  }
}

# Subnet
resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw"
  }
}

# Route Table
resource "aws_route_table" "rtable" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "route_table"
  }
}

# Route Table Association
resource "aws_route_table_association" "rtasso" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rtable.id
}

# Security Group
resource "aws_security_group" "sgroup" {
  vpc_id = aws_vpc.vpc.id
  name   = var.ecs_sg

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sgroup"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_cluster
}

resource "aws_ecs_task_definition" "ecs_task_def" {
  family                   = "service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"  # Task-level CPU value
  memory                   = "512"  # Task-level memory value

  container_definitions    = jsonencode([
    {
      name      = "app",
      image     = "nginx:latest",
      essential = true,
      memory    = 512,  # This can be removed or kept as additional container memory
      cpu       = 256,  # This can be removed or kept as additional container CPU
    }
  ])
}
# ECS Service
resource "aws_ecs_service" "ecs_service" {
  name            = "example"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_def.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.subnet.id]
    security_groups = [aws_security_group.sgroup.id]
    assign_public_ip = true
    # Removed assign_public_ip
  }
}
