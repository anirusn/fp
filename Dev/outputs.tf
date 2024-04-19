
output "Dev_instance_ids" {
  value = module.group16_Dev_instances.instance_ids
}

output "Dev_vpc_id" {
  value = module.group16_Dev_vpc.vpc_id
}

output "Dev_subnet_ids" {
  value = module.group16_Dev_subnets.subnet_ids
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat_gateway.id
}

output "internet_gateway_id" {
  value = module.group16_Dev_internet_gateway.internet_gateway_id
}

output "Dev_security_group_ids" {
  value = [
    module.group16_Dev_vms_sg.security_group_id,
    module.group16_Dev_bastion_sg.security_group_id
  ]
}
