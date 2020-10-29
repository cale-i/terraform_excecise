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

resource "aws_network_acl" "dmz" {
  vpc_id = aws_vpc.main.id

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  subnet_ids = [
    aws_subnet.dmz_1a.id,
    aws_subnet.dmz_1c.id,
  ]

  tags = {
    Name = "${var.prefix}-dmz"
  }
}

resource "aws_network_acl_rule" "dmz_1a" {
  network_acl_id = aws_network_acl.dmz.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_subnet.public_1a.cidr_block
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "dmz_1c" {
  network_acl_id = aws_network_acl.dmz.id
  rule_number    = 101
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_subnet.public_1c.cidr_block
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.main.id

  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id,
  ]

  tags = {
    Name = "${var.prefix}-private"
  }
}
