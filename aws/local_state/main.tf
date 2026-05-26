terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67"
    }
  }
}

provider "aws" {
  region = "ap-south-2"
}

# -----------------------------
# UBUNTU AMI (Free Tier Safe)
# -----------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "image-id"
    values = ["ami-024ebedf48d280810"]
  }
}

# -----------------------------
# SECURITY GROUP (SSH ONLY)
# -----------------------------
resource "aws_security_group" "ssh_only" {
  name        = "ssh-only"
  description = "Allow SSH access only"

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
}

# -----------------------------
# EC2 INSTANCE (FREE TIER)
# -----------------------------
resource "aws_instance" "terraform_demo" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  # 🔑 IMPORTANT: replace with your AWS key pair name
  key_name = "project1"

  # Attach security group
  vpc_security_group_ids = [aws_security_group.ssh_only.id]

  # Public IP for SSH access
  associate_public_ip_address = true

  tags = {
    Name = "terraform-demo"
  }
}
