variable "subnet_id" {
  description = "ID of the subnet where the NAT Gateway will be created"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC associated with the NAT Gateway"
  type        = string
}

variable "elastic_ip_allocation_id" {
  description = "Allocation ID of the Elastic IP to associate with the NAT Gateway"
  type        = string
}
