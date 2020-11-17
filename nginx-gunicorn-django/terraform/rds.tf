##################################
# DB Parameter Group
##################################

# my.cnfに定義するDB設定は、DBパラメータグループに記述。
resource "aws_db_parameter_group" "main" {
  name   = "postgres"
  family = "postgres11"
}

###########################
# SSM Parameter data source
###########################

resource "aws_ssm_parameter" "database_user" {
  name        = "/db/user"
  value       = "testuser"
  type        = "SecureString"
  description = "DBユーザー名"

  lifecycle {
    ignore_changes = [value]
  }
}
resource "aws_ssm_parameter" "database_password" {
  name        = "/db/password"
  value       = "dummypassword"
  type        = "SecureString"
  description = "ダミーパスワード"
  # apply後にaws cli から変更

  lifecycle {
    ignore_changes = [value]
  }
}
resource "aws_ssm_parameter" "database_name" {
  name        = "/db/name"
  value       = "testdb"
  type        = "SecureString"
  description = "DBデータベース名"

  lifecycle {
    ignore_changes = [value]
  }
}



##################################
# DB Subnet Group
##################################

resource "aws_db_subnet_group" "main" {
  name = "postgres"
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id
  ]

  tags = {
    Name = var.prefix
  }
}

module "postgres_sg" {
  source      = "./modules/security_group"
  name        = "postgres-sg"
  vpc_id      = aws_vpc.main.id
  port        = 5432
  cidr_blocks = [aws_vpc.main.cidr_block]
}

##################################
# DB Instance
##################################

resource "aws_db_instance" "main" {
  identifier            = "postgres"
  engine                = "postgres"
  engine_version        = "11.9"
  instance_class        = "db.t2.micro"
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = false
  # kms keyは t2.microでは使用できない
  # storage_encrypted     = true
  # kms_key_id            = aws_kms_key.postgres.arn
  name     = aws_ssm_parameter.database_name.value
  username = aws_ssm_parameter.database_user.value

  # 下記コマンドから初期パスワードの変更を行う
  # $ aws rds modify-db-instance --db-instance-identifier 'example' --master-user-password 'NewMasterPassword!'
  password = aws_ssm_parameter.database_password.value

  multi_az                   = false
  publicly_accessible        = false # false: vpc外からのアクセス遮断
  backup_window              = "09:10-09:40"
  backup_retention_period    = 30 # バックアップ期間
  maintenance_window         = "mon:10:10-mon:10:40"
  auto_minor_version_upgrade = false
  deletion_protection        = false # for Development
  #   deletion_protection        = true # for Production
  skip_final_snapshot    = true
  port                   = 5432
  apply_immediately      = false
  vpc_security_group_ids = [module.postgres_sg.security_group_id]
  parameter_group_name   = aws_db_parameter_group.main.name
  db_subnet_group_name   = aws_db_subnet_group.main.name

  lifecycle {
    ignore_changes = [password]
  }
}
