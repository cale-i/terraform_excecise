resource "aws_instance" "web-server_1a" {
  ami                         = var.amis[var.region]
  subnet_id                   = aws_subnet.public_1a.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.web-server_sg.id]
  associate_public_ip_address = "true"
  key_name                    = aws_key_pair.auth.id
  user_data                   = var.web-server_user_data

  tags = {
    Name = "rs-web-server_1a"
  }
}
resource "aws_instance" "web-server_1c" {
  ami                         = var.amis[var.region]
  subnet_id                   = aws_subnet.public_1c.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.web-server_sg.id]
  associate_public_ip_address = "true"
  key_name                    = aws_key_pair.auth.id
  user_data                   = var.web-server_user_data

  tags = {
    Name = "rs-web-server_1c"
  }
}

###########################################
# EC2 Public Security Group
###########################################

resource "aws_security_group" "web-server_sg" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "rs-web-server_sg"
  }
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web-server_sg.id
}

resource "aws_security_group_rule" "http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web-server_sg.id
}

resource "aws_security_group_rule" "https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web-server_sg.id
}

resource "aws_security_group_rule" "all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web-server_sg.id
}
