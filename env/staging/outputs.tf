
output "staging_instance_ids" {
  value = module.group16_staging_instances.instance_ids
}

output "staging_vpc_id" {
  value = module.group16_staging_vpc.vpc_id
}

output "staging_subnet_ids" {
  value = module.group16_staging_subnets.subnet_ids
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat_gateway.id
}

output "internet_gateway_id" {
  value = module.group16_staging_internet_gateway.internet_gateway_id
}

output "staging_security_group_ids" {
  value = [
    module.group16_staging_vms_sg.security_group_id,
    module.group16_staging_bastion_sg.security_group_id
  ]
}

