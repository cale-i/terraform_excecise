# HTTPS時コメントアウト外す


###################
# Security Group for ALB
###################

module "alb_sg" {
  source      = "./modules/security_group"
  name        = "alb-sg"
  vpc_id      = aws_vpc.main.id
  port        = 80
  cidr_blocks = ["0.0.0.0/0"]
}

# HTTPS時コメントアウト外す
# module "https_sg" {
#   source      = "./modules/security_group"
#   name        = "https-sg"
#   vpc_id      = aws_vpc.main.id
#   port        = 443
#   cidr_blocks = ["0.0.0.0/0"]
# }

###################
# Application Load Balancer
###################

resource "aws_lb" "main" {
  name                       = var.prefix
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = false # for development
  #   enable_deletion_protection = true # for projection

  subnets = [
    aws_subnet.public_1a.id,
    aws_subnet.public_1c.id,
  ]

  access_logs {
    bucket  = aws_s3_bucket.alb_log.id
    enabled = true
  }

  security_groups = [
    module.alb_sg.security_group_id,
    # HTTPS時コメントアウト外す
    # module.https_sg.alb_sgy_group_id, 
  ]
}
###################
# HTTP Listener
###################

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "OK"
      status_code  = "200"
    }
  }
}

###################
# HTTPS Listener
###################

# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.main.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   certificate_arn   = aws_acm_certificate.main.arn
#   ssl_policy        = "ELBSecurityPolicy-2016-08" # AWS推奨のセキュリティポリシー

#   default_action {
#     type = "fixed-response"

#     fixed_response {
#       content_type = "text/plain"
#       message_body = "OK"
#       status_code  = "200"
#     }
#   }
# }

###################
# Redirect Listener 
###################

# HTTPS時コメントアウト外す
# # HTTP to HTTPS
# resource "aws_lb_listener" "redirect_http_to_https" {
#   load_balancer_arn = aws_lb.main.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type = "redirect"

#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }

###################
# Request Forwarding
###################

# Target Group(ALBがリクエストをフォワードする対象)

resource "aws_lb_target_group" "main" {
  name        = var.prefix
  target_type = "ip" # lambd:"lambda" EC2 instance: EC2 instance id
  vpc_id      = aws_vpc.main.id
  port        = 80
  # HTTPSの終端をALBにする場合、protocolには「HTTP」を指定する。
  protocol             = "HTTP"
  deregistration_delay = 300

  health_check {
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
    port                = "traffic-port" # traffic-port に設定した場合、上記port番号(80)が使用される
    protocol            = "HTTP"
  }

  depends_on = [aws_lb.main]
}

###################
# Listener Rule
###################

# HTTPS時コメントアウト外す
# resource "aws_lb_listener_rule" "https" {
#   listener_arn = aws_lb_listener.https.arn
#   priority     = 100

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.main.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/*"]
#     }
#   }
# }

# HTTPS時コメントアウトする
resource "aws_lb_listener_rule" "http" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

###################
# output
###################


output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

