variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_instance_tenancy" {
  description = "The allowed tenancy of instances launched into the VPC"
  type        = string
  default     = "default"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}
