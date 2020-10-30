variable "region" {
  default = "ap-northeast-1"
}

variable "prefix" {
  default = "ecs"
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
