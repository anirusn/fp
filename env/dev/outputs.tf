
output "dev_instance_ids" {
  value = module.group16_dev_instances.instance_ids
}

output "dev_vpc_id" {
  value = module.group16_dev_vpc.vpc_id
}

output "dev_subnet_ids" {
  value = module.group16_dev_subnets.subnet_ids
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat_gateway.id
}

output "internet_gateway_id" {
  value = module.group16_dev_internet_gateway.internet_gateway_id
}

output "dev_security_group_ids" {
  value = [
    module.group16_dev_vms_sg.security_group_id,
    module.group16_dev_bastion_sg.security_group_id
  ]
}

