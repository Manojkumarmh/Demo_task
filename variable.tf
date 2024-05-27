variable "aws_region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "my-ecs-cluster"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "security_group_name" {
  default = "ecs-sg"
}

variable "allowed_ports" {
  type    = list(number)
  default = [80, 443]
}
