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
