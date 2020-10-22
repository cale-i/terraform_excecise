terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
    profile = "default"
    region = var.region
}

resource "aws_vpc" "simple-ec2_vpc" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "simple-ec2_public_subnet" {
    vpc_id     = aws_vpc.simple-ec2_vpc.id
    cidr_block = "10.0.0.0/24"
}

resource "aws_internet_gateway" "simple-ec2_igw" {
    vpc_id = aws_vpc.simple-ec2_vpc.id
}

resource "aws_route_table" "simple-ec2_public_rtb" {
    vpc_id = aws_vpc.simple-ec2_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.simple-ec2_igw.id
    }
}

resource "aws_route_table_association" "simple-ec2_public_a" {
    subnet_id      = aws_subnet.simple-ec2_public_subnet.id
    route_table_id = aws_route_table.simple-ec2_public_rtb.id
}

resource "aws_security_group" "simple-ec2_sg" {
    vpc_id = aws_vpc.simple-ec2_vpc.id
}

resource "aws_security_group_rule" "ssh" {
    type              = "ingress"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.simple-ec2_sg.id
}

resource "aws_security_group_rule" "http" {
    type              = "ingress"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.simple-ec2_sg.id
}

resource "aws_security_group_rule" "https" {
    type              = "ingress"
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.simple-ec2_sg.id
}

resource "aws_security_group_rule" "all" {
    type              = "egress"
    from_port         = 0
    to_port           = 65535
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.simple-ec2_sg.id
}

resource "aws_instance" "simple-ec2" {
  ami                        = var.amis[var.region]
  subnet_id                  = aws_subnet.simple-ec2_public_subnet.id
  instance_type              = "t2.micro"
  vpc_security_group_ids     = [aws_security_group.simple-ec2_sg.id]
 associate_public_ip_address = "true"
}

output "ec2-ip" {
    value = aws_instance.simple-ec2.public_ip
}