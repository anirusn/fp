# modules/multiple_instances/output.tf

output "instance_ids" {
  value = aws_instance.instances[*].id
}

output "instance_public_ip_addresses" {
  value = [for instance in aws_instance.instances : instance.*.associate_public_ip_address]
}