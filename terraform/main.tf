provider "aws" {
  region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create Subnets
resource "aws_subnet" "example_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.example_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.example_vpc.cidr_block, 8, count.index) # subnet CIDR block logic
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.example_vpc.id
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# Associate Subnets with Route Table
resource "aws_route_table_association" "subnet_associations" {
  count          = 2
  subnet_id      = aws_subnet.example_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

# IAM Role for Node Group
resource "aws_iam_role" "eks_node_group_role" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach Policies to IAM Role
resource "aws_iam_role_policy_attachment" "eks_node_group_role_attachment" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy_attachment" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_registry_policy_attachment" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# EKS Cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "foxops"
  cluster_version = "1.27"
  vpc_id          = aws_vpc.example_vpc.id
  subnet_ids      = aws_subnet.example_subnet[*].id
}

# EKS Node Group
resource "aws_eks_node_group" "example_node_group" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "example-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
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

  ami_type = "AL2_x86_64"

  tags = {
    Name = "example-node-group"
  }
}

# Application Load Balancer
resource "aws_lb" "example_lb" {
  name               = "example-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.example_subnet[*].id
}

# Listener for Load Balancer
resource "aws_lb_listener" "example_listener" {
  load_balancer_arn = aws_lb.example_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example_tg.arn
  }
}

# Target Group for Load Balancer
resource "aws_lb_target_group" "example_tg" {
  name     = "example-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.example_vpc.id
}
