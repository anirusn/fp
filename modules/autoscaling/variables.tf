variable "instance_id" {
  description = "ID of the source instance for creating AMI"
}

variable "ami_name" {
  description = "Name of the AMI"
}

variable "ami_tag_name" {
  description = "Tag name for the AMI"
}

variable "launch_template_name" {
  description = "Name of the Launch Template"
}

variable "instance_type" {
  description = "Instance type for the Launch Template"
}

variable "key_name" {
  description = "Name of the key pair"
}

variable "security_group_id" {
  description = "ID of the security group"
}

variable "volume_size" {
  description = "Size of the EBS volume in GB"
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group"
}

variable "min_size" {
  description = "Minimum size of the Auto Scaling Group"
}

variable "max_size" {
  description = "Maximum size of the Auto Scaling Group"
}

variable "desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the Auto Scaling Group"
}

variable "instance_tag_name" {
  description = "Tag name for the instances"
}

variable "scale_out_policy_name" {
  description = "Name of the scale out policy"
}

variable "scale_out_scaling_adjustment" {
  description = "Scaling adjustment for scale out policy"
}

variable "scale_out_cooldown" {
  description = "Cooldown period for scale out policy"
}

variable "scale_in_policy_name" {
  description = "Name of the scale in policy"
}

variable "scale_in_scaling_adjustment" {
  description = "Scaling adjustment for scale in policy"
}

variable "scale_in_cooldown" {
  description = "Cooldown period for scale in policy"
}
