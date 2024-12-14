provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "example_subnet" {
  count             = 2
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.example_vpc.cidr_block, 8, count.index)
  availability_zone = element(var.availability_zones, count.index)
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "foxops"
  cluster_version = "1.21"
  vpc_id          = aws_vpc.example_vpc.id
  subnet_ids      = aws_subnet.example_subnet[*].id
}

resource "aws_eks_node_group" "example_node_group" {
  cluster_name    = module.eks.cluster_id
  node_group_name = "example-node-group"
  node_role_arn   = module.eks.node_groups["eks_nodes"].node_instance_role_arn
  subnet_ids      = aws_subnet.example_subnet[*].id

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 2
  }

  instance_types = ["t3.medium"]
  remote_access {
    ec2_ssh_key = "devopsfox"
  }

  tags = {
    Name = "example-node-group"
  }
}

resource "aws_lb" "example_lb" {
  name               = "example-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.example_subnet[*].id
}

resource "aws_lb_listener" "example_listener" {
  load_balancer_arn = aws_lb.example_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "arn:aws:acm:us-east-1:account-id:certificate/certificate-id"  # Replace with your certificate ARN

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example_tg.arn
  }
}

resource "aws_lb_target_group" "example_tg" {
  name     = "example-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.example_vpc.id
}
