variable "route_table_associations" {
  type = list(object({
    subnet_id      = string
    route_table_id = string
  }))
}
