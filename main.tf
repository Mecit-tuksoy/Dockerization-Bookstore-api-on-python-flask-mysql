terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "key-name" {
  default = "firstkey"
}

resource "aws_security_group" "tf-docker-sec-gr" {
  name = "docker-sec-gr"
  tags = {
    Name = "docker-sec-group"
  }
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
data "aws_ami" "amazon-linux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

variable "git-name" {
  default = "********"
}

variable "git-token" {
  default = "********"
}
resource "aws_instance" "tf-docker-ec2" {
  ami = data.aws_ami.amazon-linux.id
  instance_type = "t2.micro"
  key_name = var.key-name
  vpc_security_group_ids = [aws_security_group.tf-docker-sec-gr.id]
  tags = {
    Name = "Web Server of Bookstore"
  }
  user_data = templatefile("user-data.sh", { user-data-git-token = var.git-token, user-data-git-name = var.git-name })
}

output "website" {
  value = "http://${aws_instance.tf-docker-ec2.public_dns}"
}
