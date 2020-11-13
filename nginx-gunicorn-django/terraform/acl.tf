resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.main.id

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  subnet_ids = [
    aws_subnet.public_1a.id,
    aws_subnet.public_1c.id,
  ]

  tags = {
    Name = "${var.prefix}-public"
  }
}

resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.main.id

  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id,
  ]
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.0.0/16"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.0.0/16"
    from_port  = 5432
    to_port    = 5432
  }

  tags = {
    Name = "${var.prefix}-private"
  }
}
