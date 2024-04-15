# Create AMI from instance
resource "aws_ami_from_instance" "prod_ami" {
  source_instance_id = var.instance_id
  name               = var.ami_name
  tags = {
    Name = var.ami_tag_name
  }
}

# Create Launch Template
resource "aws_launch_template" "example_lt" {
  name        = var.launch_template_name
  image_id    = aws_ami_from_instance.prod_ami.id
  instance_type            = var.instance_type
  key_name                 = var.key_name
  vpc_security_group_ids   = [var.security_group_id]

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = var.volume_size
      volume_type = "gp2"
    }
  }
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "example_asg" {
  name                      = var.asg_name
  launch_template {
    id                      = aws_launch_template.example_lt.id
    version                 = aws_launch_template.example_lt.latest_version
  }
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = "EC2"
  termination_policies      = ["Default"]

  tag {
    key                 = "Name"
    value               = var.instance_tag_name
    propagate_at_launch = true
  }
}

# Create Scaling Policy to scale out
resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = var.scale_out_policy_name
  scaling_adjustment     = var.scale_out_scaling_adjustment
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.scale_out_cooldown
  autoscaling_group_name = aws_autoscaling_group.example_asg.name
}

# Create Scaling Policy to scale in
resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = var.scale_in_policy_name
  scaling_adjustment     = var.scale_in_scaling_adjustment
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.scale_in_cooldown
  autoscaling_group_name = aws_autoscaling_group.example_asg.name
}
