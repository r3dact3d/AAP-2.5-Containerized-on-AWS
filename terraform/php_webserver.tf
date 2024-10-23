# Resource file 

terraform {
  required_providers {
    ansible = {
      version = "~> 1.1.0"
      source  = "terraform-ansible.com/ansibleprovider/ansible"
    }
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_vpc" "php_vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"

  tags = {
    Name      = "PHP-VPC"
    Terraform = "true"
  }
}

resource "aws_internet_gateway" "php_igw" {
  vpc_id = aws_vpc.php_vpc.id

  tags = {
    Name      = "PHP_IGW"
    Terraform = "true"
  }
}

resource "aws_route_table" "php_pub_igw" {
  vpc_id = aws_vpc.php_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.php_igw.id
  }

  tags = {
    Name      = "PHP-RouteTable"
    Terraform = "true"
  }
}

resource "aws_subnet" "php_subnet" {
  availability_zone       = "us-east-1a"
  cidr_block              = "10.1.0.0/24"
  map_public_ip_on_launch = "true"
  vpc_id                  = aws_vpc.php_vpc.id

  tags = {
    Name      = "PHP-Subnet"
    Terraform = "true"
  }
}

resource "aws_route_table_association" "php_rt_subnet_public" {
  subnet_id      = aws_subnet.php_subnet.id
  route_table_id = aws_route_table.php_pub_igw.id
}

resource "aws_security_group" "php_security_group" {
  name        = "php-sg"
  description = "Security Group for PHP webserver"
  vpc_id      = aws_vpc.php_vpc.id

  tags = {
    Name      = "PHP-Security-Group"
    Terraform = "true"
  }
}

resource "aws_security_group_rule" "http_ingress_access" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.php_security_group.id
}

resource "aws_security_group_rule" "egress_access" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.php_security_group.id
}

resource "aws_instance" "php_instance" {
  instance_type               = "t2.nano"
  vpc_security_group_ids      = [aws_security_group.php_security_group.id]
  associate_public_ip_address = true
  user_data                   = file("user_data.txt")
  ami                         = "ami-0aba0ea987d0d7530"
  availability_zone           = "us-east-1a"
  subnet_id                   = aws_subnet.php_subnet.id

  tags = {
    Name      = "php-webserver1"
    Terraform = "true"
  }
}