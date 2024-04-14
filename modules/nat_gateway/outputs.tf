output "nat_gateway_id" {
  description = "ID of the created NAT Gateway"
  value       = aws_nat_gateway.my_nat_gateway.id
}

output "eip_id" {
  description = "ID of the created Elastic IP"
  value       = aws_eip.my_eip.id
}
