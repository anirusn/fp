# Create Application Load Balancer
resource "aws_lb" "example_alb" {
  name               = var.alb_name
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = [var.security_group_id]
  internal           = false  
  enable_deletion_protection = var.enable_deletion_protection

  tags = {
    Name = var.alb_name
  }
}

# Create Target Group
resource "aws_lb_target_group" "example_target_group" {
  name     = var.target_group_name
  port     = var.target_group_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  # health_check {
  #   path                = var.health_check_path
  #   port                = var.health_check_port
  #   protocol            = "HTTP"
  #   interval            = var.health_check_interval
  #   timeout             = var.health_check_timeout
  #   healthy_threshold   = var.health_check_healthy_threshold
  #   unhealthy_threshold = var.health_check_unhealthy_threshold
  # }
}

# Create Listener
resource "aws_lb_listener" "example_listener" {
  load_balancer_arn = aws_lb.example_alb.arn
  port              = var.listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example_target_group.arn
  }
}

#Create Listener Rule
resource "aws_lb_listener_rule" "example_listener_rule" {
  listener_arn = aws_lb_listener.example_listener.arn
  priority     = var.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example_target_group.arn
  }

  condition {
    path_pattern {
      values = [var.listener_rule_path]
    }
  }
}

#Attach Target Group to Target
resource "aws_lb_target_group_attachment" "example_attachment" {
  target_group_arn = aws_lb_target_group.example_target_group.arn
  target_id        = var.target_id
  port             = 80
}
