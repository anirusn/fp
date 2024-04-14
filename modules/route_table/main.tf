resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.gateway_id
  }
  
  dynamic "route" {
    for_each = var.vpc_peering_connection_id != null ? [1] : []
    content {
      cidr_block                 = var.peered_cidr_block
      vpc_peering_connection_id  = var.vpc_peering_connection_id
    }
  }

  tags = {
    Name = "Route Table"
  }
}