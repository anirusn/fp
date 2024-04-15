
output "prod_instance_ids" {
  value = module.Group16_prod_instances.instance_ids
}

output "prod_vpc_id" {
  value = module.Group16_prod_vpc.vpc_id
}

output "prod_subnet_ids" {
  value = module.Group16_prod_subnets.subnet_ids
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat_gateway.id
}

output "internet_gateway_id" {
  value = module.Group16_prod_internet_gateway.internet_gateway_id
}

output "prod_security_group_ids" {
  value = [
    module.Group16_prod_vms_sg.security_group_id,
    module.Group16_prod_bastion_sg.security_group_id
  ]
}

