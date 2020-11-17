variable "region" {
  default = "ap-northeast-1"
}
# variable "region" {
#   default = data.aws_region.current.name
# }

variable "prefix" {
  default = "ecs"
}

variable "docker_dir" {
  default = "../backend/"
}

variable "container_name" {
  default = "webserver"
}
variable "docker_image_tag" {
  default = "latest"
}

variable "domain" {
  default = "random-stat.work"
}

variable "bucket_account_id" {
  type = map
  default = {
    "ap-northeast-1" = "582318560864"
  }
}

variable "db_password" {}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

data "aws_region" "current" {}

output "region_name" {
  value = data.aws_region.current.name
}
