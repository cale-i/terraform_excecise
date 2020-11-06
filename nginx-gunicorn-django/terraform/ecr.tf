###########################################
# ECR Repository
###########################################

resource "aws_ecr_repository" "webserver" {
  name                 = "webserver"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

#######################
# ECR Lifecycle Policy
#######################

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.webserver.name

  policy = <<EOF
    {
      "rules": [
        {
          "rulePriority": 1,
          "description": "keep last 30 release tagged images",
          "selection": {
            "tagStatus": "tagged",
            "tagPrefixList": ["release"],
            "countType": "imageCountMoreThan",
            "countNumber": 30
          },
          "action": {
            "type": "expire"
          }
        }
      ]
    }
  EOF
}
###########################################
# Push to ECR Repository when "terraform apply"
###########################################

resource "null_resource" "default" {
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
