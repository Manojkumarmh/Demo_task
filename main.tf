# VPC
resource "aws_vpc" "example" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "example-vpc"
  }
}

# Subnet
resource "aws_subnet" "example" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "example-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "example-igw"
  }
}

# Route Table
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }

  tags = {
    Name = "example-route-table"
  }
}

# Route Table Association
resource "aws_route_table_association" "example" {
  subnet_id      = aws_subnet.example.id
  route_table_id = aws_route_table.example.id
}

# Security Group
resource "aws_security_group" "example" {
  vpc_id = aws_vpc.example.id
  name   = var.security_group_name

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
    Name = "example-sg"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "example" {
  name = var.cluster_name
}

# ECS Task Definition
resource "aws_ecs_task_definition" "example" {
  family                   = "service"
  container_definitions    = jsonencode([
    {
      name      = "app",
      image     = "nginx:latest",
      essential = true,
      memory    = 512,
      cpu       = 256,
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "example" {
  name            = "example"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.example.arn
  desired_count   = 1

  launch_type = "EC2"

  network_configuration {
    subnets         = [aws_subnet.example.id]
    security_groups = [aws_security_group.example.id]
    assign_public_ip = true
  }
}
