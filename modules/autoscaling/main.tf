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
  target_group_arns         = [var.target_group_arn] 

  tag {
    key                 = "Name"
    value               = var.instance_tag_name
    propagate_at_launch = true
  }
}


# Create CloudWatch Metric Alarms for CPU Utilization
resource "aws_cloudwatch_metric_alarm" "scale_out_cpu_alarm" {
  alarm_name          = "scale-out-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300  # 5 minutes
  statistic           = "Average"
  threshold           = 10
  alarm_description   = "Alarm to scale out when CPU utilization is above 10%"
  alarm_actions       = [aws_autoscaling_policy.scale_out_policy.arn]
  dimensions = {
    InstanceId = var.dim_instance_id
  }
}

resource "aws_cloudwatch_metric_alarm" "scale_in_cpu_alarm" {
  alarm_name          = "scale-in-cpu-utilization"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300  # 5 minutes
  statistic           = "Average"
  threshold           = 5
  alarm_description   = "Alarm to scale in when CPU utilization is below 5%"
  alarm_actions       = [aws_autoscaling_policy.scale_in_policy.arn]
  dimensions = {
    InstanceId = var.dim_instance_id
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

