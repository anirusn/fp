output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.example_alb.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.example_target_group.arn
}