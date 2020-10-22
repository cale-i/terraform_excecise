
###########################################
# VPC
###########################################

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "rs"
  }
}

###########################################
# Public Subnet
###########################################

resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "rs-public_1a"
  }
}

resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "rs-public_1c"
  }
}

###########################################
# Private Subnet
###########################################

resource "aws_subnet" "private_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "rs-private_1a"
  }
}

resource "aws_subnet" "private_1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false

  tags = {
    Name = "rs-private_1c"
  }
}

###########################################
# Internet Gateway
###########################################

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "rs-igw"
  }
}

###########################################
# Nat Gateway
###########################################

resource "aws_eip" "nat_1a" {
  vpc = true

  tags = {
    Name = "rs-nat_1a"
  }
}

resource "aws_nat_gateway" "nat_gw_1a" {
  subnet_id     = aws_subnet.public_1a.id
  allocation_id = aws_eip.nat_1a.id

  tags = {
    Name = "rs-nat_gw_1a"
  }
}

resource "aws_eip" "nat_1c" {
  vpc = true

  tags = {
    Name = "rs-nat_1c"
  }
}

resource "aws_nat_gateway" "nat_gw_1c" {
  subnet_id     = aws_subnet.public_1c.id
  allocation_id = aws_eip.nat_1c.id

  tags = {
    Name = "rs-nat_gw_1c"
  }
}

###########################################
# Public Route Table
###########################################

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "rs-public_rt"
  }
}

resource "aws_route_table_association" "public_1a_rta" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_1c_rta" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_1a_rt" {
  vpc_id = aws_vpc.main.id

  route {
    nat_gateway_id = aws_nat_gateway.nat_gw_1a.id
    cidr_block     = "0.0.0.0/0"

  }

  tags = {
    Name = "rs-private_1a"
  }
}

###########################################
# Private Route Table
###########################################

resource "aws_route_table" "private_1c_rt" {
  vpc_id = aws_vpc.main.id

  route {
    nat_gateway_id = aws_nat_gateway.nat_gw_1c.id
    cidr_block     = "0.0.0.0/0"

  }

  tags = {
    Name = "rs-private_1c"
  }
}

resource "aws_route_table_association" "private_1a_rta" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private_1a_rt.id
}

resource "aws_route_table_association" "private_1c_rta" {
  subnet_id      = aws_subnet.private_1c.id
  route_table_id = aws_route_table.private_1c_rt.id
}
