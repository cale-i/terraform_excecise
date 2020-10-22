###########################################
# ELB
###########################################

resource "aws_lb" "web-server_alb" {
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = [
    aws_subnet.public_1a.id,
    aws_subnet.public_1c.id
  ]

  tags = {
    Name = "rs_alb"
  }
}

###########################################
# ELB Security Group
###########################################

resource "aws_security_group" "alb" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rs-web-server_sg_alb"
  }
}

###########################################
# ALB Listener
###########################################

resource "aws_lb_listener" "web-server_alb_listener" {
  load_balancer_arn = aws_lb.web-server_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-server_alb_tg.arn
  }
}

resource "aws_lb_listener_rule" "forward" {
  listener_arn = aws_lb_listener.web-server_alb_listener.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-server_alb_tg.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

###########################################
# ALB Target Group
###########################################

resource "aws_lb_target_group" "web-server_alb_tg" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/index.html"
  }

  tags = {
    Name = "rs_alb_tg"
  }
}

resource "aws_lb_target_group_attachment" "web-server_1a" {
  target_group_arn = aws_lb_target_group.web-server_alb_tg.arn
  target_id        = aws_instance.web-server_1a.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web-server_1c" {
  target_group_arn = aws_lb_target_group.web-server_alb_tg.arn
  target_id        = aws_instance.web-server_1c.id
  port             = 80
}