variable "region" {
  default = "ap-northeast-1"
}

variable "amis" {
  type = map
  default = {
    "ap-northeast-1" = "ami-0ce107ae7af2e92b5" # Amazon Linux 2 AMI
    "us-east-1"      = "ami-0947d2ba12ee1ff75" # Amazon Linux 2 AMI
  }
}

variable "key_name" {
}

variable "public_key_path" {
}

variable "web-server_user_data" {
  default = <<EOF
  #!/bin/bash
  yum update -y
  yum install -y httpd
  yum install -y mysql
  systemctl start httpd
  systemctl enable httpd
  usermod -a -G apache ec2-user
  chown -R ec2-user:apache /var/www
  chmod 2775 /var/www
  find /var/www -type d -exec chmod 2775 {} \;
  find /var/www -type f -exec chmod 2775 {} \;
  echo `hostname` > /var/www/html/index.html
  EOF
}

variable "db_username" {
}

variable "db_password" {
}