# Resource file 

terraform {
  required_providers {
    ansible = {
      version = "~> 1.3.0"
      source  = "ansible/ansible"
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

# Add key for ssh connection
resource "aws_key_pair" "my_key" {
  key_name   = "my_key"
  public_key = "my_public_key_value"
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
  availability_zone       = "us-east-2a"
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

# Set ami for ec2 instance
data "aws_ami" "rhel" {
  most_recent = true
  filter {
    name   = "name"
    values = ["RHEL-9.4.0_HVM*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["309956199498"]
}

resource "aws_instance" "php_instance" {
  instance_type               = "t2.nano"
  vpc_security_group_ids      = [aws_security_group.php_security_group.id]
  associate_public_ip_address = true
  key_name        = aws_key_pair.my_key.key_name
  user_data                   = file("user_data.txt")
  ami                         = data.aws_ami.rhel.id
  availability_zone           = "us-east-2a"
  subnet_id                   = aws_subnet.php_subnet.id

  tags = {
    Name      = "php-webserver1"
    Terraform = "true"
  }
}

# Add created ec2 instance to ansible inventory
resource "ansible_host" "php_instance" {
  name   = aws_instance.php_instance.public_dns
  groups = ["webserver"]
  variables = {
    ansible_user                 = "ec2-user",
    ansible_ssh_private_key_file = "~/.ssh/id_rsa",
    ansible_python_interpreter   = "/usr/bin/python3",
  }
}