# Terraform state file
# terraform {
#   backend "s3" {
#     bucket         = "acs730bucket"
#     key            = "terraform.tfstate"
#     region         = "us-east-1"  
#     encrypt        = true          
#   }
# }

# Defining key pair
resource "aws_key_pair" "my_key_pair" {
  key_name   = "acs730"
  public_key = file("/home/ec2-user/environment/terraform-project/key/acs730.pub")  
}

#Defining an Image

resource "aws_ami_from_instance" "prod_ami" {
  source_instance_id = module.prod_instances.instance_ids[1]
  name        = "prod-ami"
  tags = {
    Name = "example-ami"
  }
}


# creating elastic IP
resource "aws_eip" "nat" {
   domain = "vpc"
}

# creating nat gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = module.prod_subnets.subnet_ids[0]

  tags = {
    Name = "my-nat-gateway"
  }
}

# creating internet gateway
module "my_internet_gateway" {
  source  = "/home/ec2-user/environment/terraform-project/modules/internet_gateway"
  vpc_id  = module.prod_vpc.vpc_id
}



# Launch Template for EC2 instances (VMs)
resource "aws_launch_template" "example_lt" {
  name_prefix   = "example-lt"
  image_id      = aws_ami_from_instance.prod_ami.id 
  instance_type = "t3.medium"
  key_name      = aws_key_pair.my_key_pair.key_name
  user_data     = file("/home/ec2-user/environment/terraform-project/vm_user_data.sh")
  vpc_security_group_ids = [module.prod_vms_sg.security_group_id]

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 20
      volume_type = "gp2"
    }
  }
}

# Auto Scaling Group (ASG)
resource "aws_autoscaling_group" "example_asg" {
  name                      = "example-asg"
  launch_template {
    id                      = aws_launch_template.example_lt.id
    version                 = aws_launch_template.example_lt.latest_version
  }
  min_size                  = 1
  max_size                  = 4
  desired_capacity          = 1
  vpc_zone_identifier       =  [module.prod_subnets.subnet_ids[3], module.prod_subnets.subnet_ids[4], module.prod_subnets.subnet_ids[5]]
  health_check_type         = "EC2"
  termination_policies      = ["Default"]

  tag {
    key                 = "Name"
    value               = "example-instance"
    propagate_at_launch = true
  }
}

# Scaling Policy to scale out
resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "cpu-utilization-scale-out"
  scaling_adjustment     = 1  # Increase by 1 instance
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300  # 5 minutes cooldown period
  autoscaling_group_name = aws_autoscaling_group.example_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 10  # Set the target value for CPU utilization to 10%
  }
}


# Scaling Policy to scale in
resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "cpu-utilization-scale-in"
  scaling_adjustment     = -1  # Decrease by 1 instance
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300  # 5 minutes cooldown period
  autoscaling_group_name = aws_autoscaling_group.example_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value           = 5  # Scale in if CPU utilization is below 5%

  }
}


#creating prod resources

#creating prod vpc
module "prod_vpc" {
  source = "/home/ec2-user/environment/terraform-project/modules/vpc"
  vpc_cidr_block       = "10.250.0.0/16"
  vpc_instance_tenancy = "default"
  vpc_name             = "prod-vpc"
}

#creating prod subnets
module "prod_subnets" {
  source            = "/home/ec2-user/environment/terraform-project/modules/subnet"
  subnet_names      = ["prod_public1", "prod_public2", "prod_public3", "prod_private1", "prod_private2", "prod_private3"]
  subnet_cidr_blocks = ["10.250.1.0/24", "10.250.2.0/24", "10.250.3.0/24", "10.250.4.0/24", "10.250.5.0/24", "10.250.6.0/24"]
  availability_zones = ["us-east-1b", "us-east-1c", "us-east-1d", "us-east-1b", "us-east-1c", "us-east-1d"]
  vpc_id            = module.prod_vpc.vpc_id
  
}

#creating security group for prod bastion host
module "prod_bastion_sg" {
  source              = "/home/ec2-user/environment/terraform-project/modules/security_group"
  security_group_name = "prod-security-group_bastion"
  security_group_description = "Security group for prod environment"
  vpc_id = module.prod_vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["99.227.114.52/32"]
    }
   
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}


#creating security group for prod vms

module "prod_vms_sg" {
  source              = "/home/ec2-user/environment/terraform-project/modules/security_group"
  security_group_name = "prod-security-group_vm"
  security_group_description = "Security group for prod environment"
  vpc_id = module.prod_vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks     = [] 
      security_groups = [module.prod_bastion_sg.security_group_id]
    },
    
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks     = [] 
      security_groups = [module.prod_bastion_sg.security_group_id]
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}


#creating prod instances
module "prod_instances" {
  source = "/home/ec2-user/environment/terraform-project/modules/instance"

  instances = [
    {
      name          = "prod_bastion"
      ami_id        = "ami-051f8a213df8bc089"
      instance_type = "t3.medium"
      subnet_id     = module.prod_subnets.subnet_ids[0]
      security_group_id = module.prod_bastion_sg.security_group_id
      assign_public_ip = true
      key_name    = aws_key_pair.my_key_pair.key_name
    },
    {
      name          = "prod_vm"
      ami_id        = "ami-051f8a213df8bc089"
      instance_type = "t3.medium"
      subnet_id     = module.prod_subnets.subnet_ids[4]
      security_group_id = module.prod_vms_sg.security_group_id
      user_data     = file("/home/ec2-user/environment/terraform-project/vm_user_data.sh")
      assign_public_ip = false
      key_name    = aws_key_pair.my_key_pair.key_name

    }
  ]
}


#creating prod public route table
module "prod_PublicRT" {
  source     = "/home/ec2-user/environment/terraform-project/modules/route_table"
  
  vpc_id     = module.prod_vpc.vpc_id
  gateway_id = module.my_internet_gateway.internet_gateway_id
  subnet_id  = module.prod_subnets.subnet_ids[0]
}

#creating prod private route table
module "prod_PrivateRT" {
  source     = "/home/ec2-user/environment/terraform-project/modules/route_table"
  
  vpc_id     = module.prod_vpc.vpc_id
  gateway_id = aws_nat_gateway.nat_gateway.id
  subnet_id  = module.prod_subnets.subnet_ids[3]
}

#creating prod route table asscociation
module "prod_route_table_associations" {
  source = "/home/ec2-user/environment/terraform-project/modules/route_table_association"

  route_table_associations = [
    {
      subnet_id      = module.prod_subnets.subnet_ids[0]
      route_table_id = module.prod_PublicRT.route_table_id
    },
    {
      subnet_id      = module.prod_subnets.subnet_ids[1]
      route_table_id = module.prod_PublicRT.route_table_id
    },
    {
      subnet_id      = module.prod_subnets.subnet_ids[2]
      route_table_id = module.prod_PublicRT.route_table_id
    },
    {
      subnet_id      = module.prod_subnets.subnet_ids[3]
      route_table_id = module.prod_PrivateRT.route_table_id 
    },
    {
      subnet_id      = module.prod_subnets.subnet_ids[4]
      route_table_id = module.prod_PrivateRT.route_table_id 
    },
    {
      subnet_id      = module.prod_subnets.subnet_ids[5]
      route_table_id = module.prod_PrivateRT.route_table_id 
    }
    
  ]
}


#create load balancer:
resource "aws_lb" "example_alb" {
  name               = "example-alb"
  load_balancer_type = "application"
  subnets = [module.prod_subnets.subnet_ids[0], module.prod_subnets.subnet_ids[1], module.prod_subnets.subnet_ids[2]]
  security_groups    = [module.prod_vms_sg.security_group_id]

  enable_deletion_protection = false  # Set to true if you want to enable deletion protection

  tags = {
    Name = "example-alb"
  }
}

resource "aws_lb_target_group" "example_target_group" {
  name     = "example-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.prod_vpc.vpc_id

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "example_listener" {
  load_balancer_arn = aws_lb.example_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example_target_group.arn
  }
}

resource "aws_lb_listener_rule" "example_listener_rule" {
  listener_arn = aws_lb_listener.example_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}


resource "aws_lb_target_group_attachment" "example_attachment" {
  target_group_arn = aws_lb_target_group.example_target_group.arn
  target_id        = module.prod_instances.instance_ids[0]
}
