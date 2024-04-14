variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}


variable "gateway_id" {
  description = "The ID of the Internet Gateway or NAT Gateway"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "The ID of the subnet"
  type        = string
}

variable "peered_cidr_block" {
  description = "The CIDR block of the peered VPC"
  type        = string
  default     = null
}
  
variable "vpc_peering_id" {
  description = "The ID of the VPC peering connection"
  type        = string
   default     = null
}

variable "vpc_peering_connection_id" {
  description = "The ID of the VPC peering connection"
  type        = string
  default     = null
}