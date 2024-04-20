variable "alb_name" {
  description = "Name of the Application Load Balancer"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs where the ALB will be deployed"
}

variable "security_group_id" {
  description = "ID of the security group for the ALB"
}

variable "enable_deletion_protection" {
  type        = bool
  description = "Enable deletion protection for the ALB"
}

variable "target_group_name" {
  description = "Name of the target group"
}

variable "target_group_port" {
  description = "Port for the target group"
}

variable "vpc_id" {
  description = "ID of the VPC"
}

# variable "health_check_path" {
#   description = "Path for the health check"
# }

# variable "health_check_port" {
#   description = "Port for the health check"
# }

# variable "health_check_interval" {
#   description = "Interval for the health check"
# }

# variable "health_check_timeout" {
#   description = "Timeout for the health check"
# }

# variable "health_check_healthy_threshold" {
#   description = "Healthy threshold for the health check"
# }

# variable "health_check_unhealthy_threshold" {
#   description = "Unhealthy threshold for the health check"
# }

variable "listener_port" {
  description = "Port for the listener"
}

variable "listener_rule_priority" {
  description = "Priority for the listener rule"
}

variable "listener_rule_path" {
  description = "Path pattern for the listener rule"
}

variable "target_id" {
  description = "ID of the target to attach to the target group"
}
