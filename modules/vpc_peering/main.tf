resource "aws_vpc_peering_connection" "peering_vpc1_to_vpc2" {
  vpc_id      = var.vpc1_id
  peer_vpc_id = var.vpc2_id
  auto_accept = true
}

