###############################################################################
# Pedidos360 - AWS infrastructure (network + compute)
#
# Provisions the VPC, subnets, gateways, security groups and five EC2 instances
# (one per Spring Boot microservice). API Gateway, S3 and CloudFront are in
# separate files (apigateway.tf, s3_cloudfront.tf).
###############################################################################

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  services = {
    gateway        = { port = 8080 }
    pedidos        = { port = 8081 }
    productos      = { port = 8082 }
    clientes       = { port = 8083 }
    notificaciones = { port = 8084 }
  }
  tags = {
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Environment = "shared"
  }
}

# Latest Amazon Linux 2023 AMI
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

###############################################################################
# VPC + networking
###############################################################################
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(local.tags, { Name = "${var.project_name}-vpc" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags, { Name = "${var.project_name}-igw" })
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags                    = merge(local.tags, { Name = "${var.project_name}-public-${count.index}" })
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags              = merge(local.tags, { Name = "${var.project_name}-private-${count.index}" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(local.tags, { Name = "${var.project_name}-public-rt" })
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

###############################################################################
# Security groups
###############################################################################
# EC2 microservices: allow inbound HTTP on service ports + SSH.
# For simplicity (AWS Academy, HTTP API without VPC link) the service ports are
# reachable so the public HTTP API integrations can reach them. Lock this down
# to the API Gateway managed prefix list in a hardened deployment.
resource "aws_security_group" "services" {
  name        = "${var.project_name}-services-sg"
  description = "Allow microservice ports and SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Microservice HTTP ports"
    from_port   = 8080
    to_port     = 8084
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${var.project_name}-services-sg" })
}

###############################################################################
# EC2 instances (one per microservice)
###############################################################################
resource "aws_instance" "service" {
  for_each = local.services

  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.services.id]
  key_name               = var.key_name != "" ? var.key_name : null
  iam_instance_profile   = var.ec2_instance_profile != "" ? var.ec2_instance_profile : null

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    service_name       = each.key
    service_port       = each.value.port
    artifacts_base_url = var.artifacts_base_url
    azure_tenant_id    = var.azure_tenant_id
    azure_audience     = var.azure_api_audience
    cors_origins       = join(",", var.cors_allowed_origins)
  })

  tags = merge(local.tags, {
    Name    = "${var.project_name}-${each.key}"
    Service = each.key
  })
}
