resource "aws_instance" "instances" {
  count = length(var.instances)

  ami           = var.instances[count.index].ami_id
  instance_type = var.instances[count.index].instance_type
  subnet_id     = var.instances[count.index].subnet_id
  user_data     = var.instances[count.index].user_data
  security_groups = [var.instances[count.index].security_group_id]
  associate_public_ip_address = var.instances[count.index].assign_public_ip != false  
  key_name = var.instances[count.index].key_name  

  tags = {
    Name = var.instances[count.index].name
  }
  
}