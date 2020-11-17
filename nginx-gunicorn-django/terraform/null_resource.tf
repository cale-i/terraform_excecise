###########################################
# SSM Parameter modify when "terraform apply"
###########################################

resource "null_resource" "ssm" {
  provisioner "local-exec" {
    command = "echo ${aws_db_instance.main.identifier}"
  }
  provisioner "local-exec" {
    command = "aws rds modify-db-instance --db-instance-identifier ${aws_db_instance.main.identifier} --master-user-password ${var.db_password}"
  }

  provisioner "local-exec" {
    command = "aws ssm put-parameter --name /db/password --type SecureString --value ${var.db_password} --overwrite"
  }

}
###########################################
# Push to ECR Repository when "terraform apply"
###########################################

resource "null_resource" "ecr" {
  provisioner "local-exec" {
    command = "aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.webserver.repository_url}"
  }

  provisioner "local-exec" {
    command = "docker build -t ${aws_ecr_repository.webserver.repository_url}:${var.docker_image_tag} ${var.docker_dir}"
  }

  provisioner "local-exec" {
    command = "docker push ${aws_ecr_repository.webserver.repository_url}"
  }

}
