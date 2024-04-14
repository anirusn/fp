resource "aws_route_table_association" "multiple_associations" {
  count = length(var.route_table_associations)

  subnet_id      = var.route_table_associations[count.index].subnet_id
  route_table_id = var.route_table_associations[count.index].route_table_id
}