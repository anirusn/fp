variable "subnet_names" {
  description = "List of subnet names"
  type        = list(string)
}

variable "subnet_cidr_blocks" {
  description = "List of CIDR blocks for subnets"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of the VPC associated with the subnets"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones for subnets"
  type        = list(string)
}
