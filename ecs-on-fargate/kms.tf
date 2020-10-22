resource "aws_kms_key" "postgres" {
  description             = "postgres Customer Master Key"
  enable_key_rotation     = true
  is_enabled              = true
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "postgres" {
  name          = "alias/postgres"
  target_key_id = aws_kms_key.postgres.key_id
}
