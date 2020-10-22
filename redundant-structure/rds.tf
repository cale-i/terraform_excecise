###########################################
# RDS
###########################################

resource "aws_db_instance" "rs" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  name                   = "rsdb"
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql5.7"
  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.dbsubnet.name
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rs_rds.id]

  lifecycle {
    ignore_changes = [password]
  }

  tags = {
    Name = "rs_rds"
  }
}

###########################################
# RDS Subnet Group
###########################################

resource "aws_db_subnet_group" "dbsubnet" {
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id
  ]
  tags = {
    Name = "rs_db_subnet_group"
  }
}

###########################################
# RDS Subnet
###########################################

resource "aws_security_group" "rs_rds" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "rs_rds_subnet"
  }
}