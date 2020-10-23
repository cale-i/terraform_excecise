###########################################
# VPC
###########################################

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

###########################################
# Subnet
###########################################

#####################
# Public Subnet
#####################

resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-public_1a"
  }
}

resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-public_1c"
  }
}

#####################
# Internet Gateway
#####################

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.prefix}"
  }
}

#####################
# Route Table
#####################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.prefix}-public"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.main.id
  destination_cidr_block = "0.0.0.0/0"
}

#####################
# Route Table Association
#####################

resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}



#####################
# Private Subnet DMZ
#####################

resource "aws_subnet" "dmz_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.32.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-dmz_1a"
  }
}

resource "aws_subnet" "dmz_1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.33.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-dmz_1c"
  }
}
# resource "aws_eip" "nat_gateway_1a" {
#   vpc        = true
#   depends_on = [aws_internet_gateway.main]
# }

# resource "aws_eip" "nat_gateway_1c" {
#   vpc        = true
#   depends_on = [aws_internet_gateway.main]
# }

# resource "aws_nat_gateway" "nat_gateway_1a" {
#   allocation_id = aws_eip.nat_gateway_1a.id
#   subnet_id     = aws_subnet.public_1a.id
#   depends_on    = [aws_internet_gateway.main]
# }

# resource "aws_nat_gateway" "nat_gateway_1c" {
#   allocation_id = aws_eip.nat_gateway_1c.id
#   subnet_id     = aws_subnet.public_1c.id
#   depends_on    = [aws_internet_gateway.main]
# }

#####################
# Internet Gateway for DMZ
#####################
# NATを設置する代わりにinternet_gatewayを設置し、
# network ACLで制御する
# ingress: DENY
# egress: ALLOW

# resource "aws_internet_gateway" "dmz" {
#   vpc_id = aws_vpc.main.id
# }

resource "aws_route_table" "dmz" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.prefix}-dmz"
  }
}

resource "aws_route" "dmz_1a" {
  route_table_id         = aws_route_table.dmz.id
  gateway_id             = aws_internet_gateway.main.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "dmz_1c" {
  route_table_id         = aws_route_table.dmz.id
  gateway_id             = aws_internet_gateway.main.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "dmz_1a" {
  subnet_id      = aws_subnet.dmz_1a.id
  route_table_id = aws_route_table.dmz.id
}

resource "aws_route_table_association" "dmz_1c" {
  subnet_id      = aws_subnet.dmz_1c.id
  route_table_id = aws_route_table.dmz.id
}
#####################
# Private Subnet for DB
#####################

resource "aws_subnet" "private_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.64.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.prefix}-private_1a"
  }
}

resource "aws_subnet" "private_1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.65.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.prefix}-private_1c"
  }
}

resource "aws_route_table" "private_1a" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.prefix}-private_1a"
  }
}

resource "aws_route_table" "private_1c" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.prefix}-private_1c"
  }
}

# resource "aws_route" "private_1a" {
#   route_table_id         = aws_route_table.private_1a.id
#   destination_cidr_block = "0.0.0.0/0"
# }

# resource "aws_route" "private_1c" {
#   route_table_id         = aws_route_table.private_1c.id
#   destination_cidr_block = "0.0.0.0/0"
# }

# resource "aws_route_table_association" "private_1a" {
#   subnet_id      = aws_subnet.private_1a.id
#   route_table_id = aws_route_table.private_1a.id
# }

# resource "aws_route_table_association" "private_1c" {
#   subnet_id      = aws_subnet.private_1c.id
#   route_table_id = aws_route_table.private_1c.id
# }
