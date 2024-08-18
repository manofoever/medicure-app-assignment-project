terraform {
required_providers {
aws = {
source = "hashicorp/aws"
version = "~> 5.0"
}
}
}
#configure provider
provider "aws" {
region = "us-east-1"
}

resource "aws_eip" "test_server_eip" {
  domain = "vpc"
tags = {
    Name = "test_server_eip"
  }

}

resource "aws_eip" "prod_server_eip" {
  domain = "vpc"
tags = {
    Name = "prod_server_eip"
  }
}
resource "aws_security_group" "final_proj_sg" {
  name        = "final_proj"
  description = "Security group allowing all TCP traffic on all ports"
  ingress {
    description = "SSH Port"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPs traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "All tcp traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "test_server" {
  ami           = "ami-0a0e5d9c7acc336f1" 
  instance_type = "t2.micro"

  tags = {
    Name = "test_server"
  }

  vpc_security_group_ids = [aws_security_group.final_proj_sg.id]

  key_name = "jenkins"  
  associate_public_ip_address = true
}

# Associate the first EIP with the test instance
resource "aws_eip_association" "test_eip_assoc" {
  instance_id   = aws_instance.test_server.id
  allocation_id = aws_eip.test_server_eip.id
}
resource "aws_instance" "prod_server" {
  ami           = "ami-0a0e5d9c7acc336f1"   
  instance_type = "t2.micro"

  tags = {
    Name = "prod_server"
  }

  vpc_security_group_ids = [aws_security_group.final_proj_sg.id]

  key_name = "jenkins"
  associate_public_ip_address = true
}

# Associate the first EIP with the test instance
resource "aws_eip_association" "prod_eip_assoc" {
  instance_id   = aws_instance.prod_server.id
  allocation_id = aws_eip.prod_server_eip.id
}

