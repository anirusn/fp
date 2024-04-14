output "subnet_ids" {
  description = "IDs of the created subnets"
  value       = aws_subnet.my_subnets[*].id
}
