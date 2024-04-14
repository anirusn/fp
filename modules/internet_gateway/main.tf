resource "aws_internet_gateway" "my_internet_gateway" {
  vpc_id = var.vpc_id
  tags = {
    Name = "My Internet Gateway"
  }
}
