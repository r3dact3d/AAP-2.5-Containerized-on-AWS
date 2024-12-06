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

terraform {
  backend "s3" {
    bucket = "tfstate-bucket-blinker19"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  region = "us-east-2"
}

#Generate SSH key pair 
resource "tls_private_key" "cloud_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Add key for ssh connection
resource "aws_key_pair" "cloud_key" {
  key_name   = "cloud_key"
  public_key = tls_private_key.cloud_key.public_key_openssh
}

resource "aws_vpc" "aap_vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"

  tags = {
    Name      = "aap-VPC"
    Terraform = "true"
  }
}

resource "aws_internet_gateway" "aap_igw" {
  vpc_id = aws_vpc.aap_vpc.id

  tags = {
    Name      = "AAP_IGW"
    Terraform = "true"
  }
}

resource "aws_route_table" "aap_pub_igw" {
  vpc_id = aws_vpc.aap_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aap_igw.id
  }

  tags = {
    Name      = "AAP-RouteTable"
    Terraform = "true"
  }
}

resource "aws_subnet" "aap_subnet" {
  availability_zone       = "us-east-2a"
  cidr_block              = "10.1.0.0/24"
  map_public_ip_on_launch = "true"
  vpc_id                  = aws_vpc.aap_vpc.id

  tags = {
    Name      = "AAP-Subnet"
    Terraform = "true"
  }
}

resource "aws_route_table_association" "aap_rt_subnet_public" {
  subnet_id      = aws_subnet.aap_subnet.id
  route_table_id = aws_route_table.aap_pub_igw.id
}

resource "aws_security_group" "aap_security_group" {
  name        = "aap-sg"
  description = "Security Group for AAP webserver"
  vpc_id      = aws_vpc.aap_vpc.id

  tags = {
    Name      = "AAP-Security-Group"
    Terraform = "true"
  }
}

resource "aws_security_group_rule" "http_ingress_access" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aap_security_group.id
}

resource "aws_security_group_rule" "ssh_ingress_access" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aap_security_group.id
}

resource "aws_security_group_rule" "postgresql_ingress_access" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aap_security_group.id
}

resource "aws_security_group_rule" "redis_ingress_access" {
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aap_security_group.id
}

resource "aws_security_group_rule" "secure_ingress_access" {
  type              = "ingress"
  from_port         = 8433
  to_port           = 8433
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aap_security_group.id
}

resource "aws_security_group_rule" "https_ingress_access" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aap_security_group.id
}

resource "aws_security_group_rule" "grpc_ingress_access" {
  type              = "ingress"
  from_port         = 50051
  to_port           = 50051
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aap_security_group.id
}

resource "aws_security_group_rule" "egress_access" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aap_security_group.id
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

resource "aws_instance" "aap_instance" {
  instance_type               = "t2.xlarge"
  vpc_security_group_ids      = [aws_security_group.aap_security_group.id]
  associate_public_ip_address = true
  key_name        = aws_key_pair.cloud_key.key_name
  user_data                   = file("user_data.txt")
  ami                         = data.aws_ami.rhel.id
  availability_zone           = "us-east-2a"
  subnet_id                   = aws_subnet.aap_subnet.id

# Specify the root block device to adjust volume size
  root_block_device {
    volume_size = 100        # Set desired size in GB (e.g., 100 GB)
    volume_type = "gp3"      # Optional: Specify volume type (e.g., "gp3" for general purpose SSD)
    delete_on_termination = true  # Optional: Automatically delete volume on instance termination
  }
  
  tags = {
    Name      = "aap-controller"
    Terraform = "true"
  }
}

resource "null_resource" "hostname_update" {
  depends_on = [aws_instance.aap_instance]

  provisioner "remote-exec" {
    inline = [
      # Register Red Hat Host
      "sudo rhc connect --activation-key=<activation_key_name> --organization=<organization_ID>",
      
      # Ensure stuff is installed
      "sudo dnf install -y ansible-core wget git-core rsync vim",

      # Set hostname
      "sudo hostnamectl set-hostname ${aws_instance.aap_instance.public_dns}",

      # Download and extract the setup file
      "wget https://github.com/r3dact3d/Trial-Project/raw/refs/heads/ansible/post_data/ansible-automation-platform-containerized-setup-2.5-6.tar.gz",
      "file ansible-automation-platform-containerized-setup-2.5-6.tar.gz",
      "tar xfvz ansible-automation-platform-containerized-setup-2.5-6.tar.gz",
      "sleep 45",

      # Configure and run the playbook
      "cd ansible-automation-platform-containerized-setup-2.5-6",
      "sed -i 's/<set your own>/new-install-password/g' inventory-growth",
      "sed -i 's/aap.example.org/${aws_instance.aap_instance.public_dns}/g' inventory-growth",
      "sed -i 's/<your RHN username>/rhn_user/g' inventory-growth",
      "sed -i 's/<your RHN password>/rhn_pass/g' inventory-growth",
      #"nohup ansible-playbook -i inventory-growth ansible.containerized_installer.install -e ansible_connection=local & 2>/dev/null",
    ]
    
    
    connection {
      type        = "ssh"
      host        = aws_instance.aap_instance.public_ip
      user        = "ec2-user"
      private_key = tls_private_key.cloud_key.private_key_pem
    }
  }
}

# Add created ec2 instance to ansible inventory
resource "ansible_host" "aap_instance" {
  name   = aws_instance.aap_instance.public_dns
  groups = ["gateway"]
  variables = {
    ansible_user                 = "ec2-user",
    ansible_ssh_private_key_file = "~/.ssh/id_rsa",
    ansible_python_interpreter   = "/usr/bin/python3",
  }
}


