variable "instances" {
  type = list(object({
    name          = string
    ami_id        = string
    instance_type = string
    subnet_id     = string
    user_data     = optional(string)
    security_group_id = string
    assign_public_ip = optional(bool)
    key_name = string
  }))
}
