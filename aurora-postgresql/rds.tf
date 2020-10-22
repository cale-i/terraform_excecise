##################################
# DB Parameter Group
##################################

resource "aws_db_parameter_group" "postgresql" {
  name   = "postgresql"
  family = "aurora-postgresql11"

  tags = {
    Name = "${var.prefix}-postgresql"
  }
}


resource "aws_rds_cluster_parameter_group" "postgresql" {
  name   = "postgresql"
  family = "aurora-postgresql11"

  tags = {
    Name = "${var.prefix}-postgresql"
  }

  # install libraries
  parameter {
    name         = "shared_preload_libraries"
    value        = "pg_stat_statements ,pg_hint_plan ,pgaudit"
    apply_method = "pending-reboot"
  }

  # audit setting
  parameter {
    name         = "pgaudit.log_catalog"
    value        = true
    apply_method = "immediate"
  }
  parameter {
    name         = "pgaudit.log_parameter"
    value        = true
    apply_method = "immediate"
  }
  parameter {
    name         = "pgaudit.log_relation"
    value        = true
    apply_method = "immediate"
  }
  parameter {
    name         = "pgaudit.log_statement_once"
    value        = true
    apply_method = "immediate"
  }
  parameter {
    name         = "pgaudit.log"
    value        = "ddl ,misc ,role"
    apply_method = "immediate"
  }
  parameter {
    name         = "pgaudit.role"
    value        = "rds_pgaudit"
    apply_method = "immediate"
  }

  # no local
  parameter {
    name         = "lc_messages"
    value        = "C"
    apply_method = "immediate"
  }
  parameter {
    name         = "lc_monetary"
    value        = "C"
    apply_method = "immediate"
  }
  parameter {
    name         = "lc_numeric"
    value        = "C"
    apply_method = "immediate"
  }
  parameter {
    name         = "lc_time"
    value        = "C"
    apply_method = "immediate"
  }
}

resource "aws_rds_cluster" "postgresql" {
  cluster_identifier = "postgresql"
  engine             = "aurora-postgresql"
  engine_version     = "11.7"
  engine_mode        = "provisioned"
  database_name      = "postgresql"
  master_username    = "postgres"
  master_password    = "initial_password"
  storage_encrypted  = true

  apply_immediately = false

  db_subnet_group_name   = aws_db_subnet_group.postgresql.name
  vpc_security_group_ids = [module.postgresql-sg.security_group_id]
  port                   = 5432

  backup_retention_period = 1
  copy_tags_to_snapshot   = true
  deletion_protection     = false
  skip_final_snapshot     = true
  # final_snapshot_identifier = "sample-aurora-postgre" # must be provided if skip_final_snapshot is set to false.

  enabled_cloudwatch_logs_exports = ["postgresql"]

  preferred_maintenance_window = "Mon:03:00-Mon:04:00"
  preferred_backup_window      = "02:00-02:30"


  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.postgresql.name

  lifecycle {
    ignore_changes = [master_password]
  }

  tags = {
    Name = var.prefix
  }
}

##################################
# DB Subnet Group
##################################

resource "aws_db_subnet_group" "postgresql" {
  name = "postgresql"
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id
  ]

  tags = {
    Name = "${var.prefix}"
  }
}

##################################
# DB Instance
##################################

resource "aws_rds_cluster_instance" "postgresql" {
  count              = 1
  identifier         = "postgresql"
  cluster_identifier = aws_rds_cluster.postgresql.cluster_identifier
  instance_class     = "db.t3.medium"
  engine             = "aurora-postgresql"
  engine_version     = "11.7"

  # monitoring
  # performance_insights_enabled = false # default false
  # monitoring_interval          = 60    # 0, 1, 5, 10, 15, 30, 60 (seconds). default 0 (off)
  # monitoring_role_arn          = aws_iam_role.monitoring_role.arn

  # maintenance window

  # options
  db_parameter_group_name    = aws_db_parameter_group.postgresql.name
  auto_minor_version_upgrade = false


  tags = {
    Name = "${var.prefix}"
  }
}

#################
# Security Group
#################

module "postgresql-sg" {
  source      = "./modules/security_group"
  name        = "${var.prefix}-postgresql-sg"
  vpc_id      = aws_vpc.main.id
  port        = 5432
  cidr_blocks = [aws_vpc.main.cidr_block]
}
