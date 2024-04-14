resource "aws_eip" "my_eip" {
  vpc = true
}

resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = var.elastic_ip_allocation_id
  subnet_id     = var.subnet_id
  tags = {
    Name = "My NAT Gateway"
  }
}
