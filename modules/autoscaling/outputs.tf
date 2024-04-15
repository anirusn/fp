output "ami_id" {
  description = "ID of the created AMI"
  value       = aws_ami_from_instance.prod_ami.id
}

output "launch_template_id" {
  description = "ID of the created Launch Template"
  value       = aws_launch_template.example_lt.id
}

output "autoscaling_group_name" {
  description = "Name of the created Auto Scaling Group"
  value       = aws_autoscaling_group.example_asg.name
}
