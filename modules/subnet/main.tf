resource "aws_subnet" "my_subnets" {
  count             = length(var.subnet_names)
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = var.subnet_names[count.index]
  }
}
