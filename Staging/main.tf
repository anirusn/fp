#Terraform state file
terraform {
  backend "s3" {
    bucket  = "fpbucket730"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

# Defining key pair
resource "aws_key_pair" "group16_staging_key_pair" {
  key_name   = "acs730"
  public_key = file("/home/ec2-user/environment/terraform-project/key/acs730.pub")
}

# creating elastic IP
resource "aws_eip" "nat" {
  domain = "vpc"
}

# creating nat gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = module.group16_staging_subnets.subnet_ids[0]

  tags = {
    Name = "group16-staging-nat-gateway"
  }
}

# creating internet gateway
module "group16_staging_internet_gateway" {
  source = "/home/ec2-user/environment/terraform-project/modules/internet_gateway"
  vpc_id = module.group16_staging_vpc.vpc_id
}


module "group16_staging_asg" {
  source = "/home/ec2-user/environment/terraform-project/modules/autoscaling"

  instance_id                  = module.group16_staging_instances.instance_ids[1]
  ami_name                     = "group16-staging-ami"
  ami_tag_name                 = "group16-staging-ami"
  launch_template_name         = "group16_staging_lt"
  instance_type                = "t3.small"
  key_name                     = aws_key_pair.group16_staging_key_pair.key_name
  security_group_id            = module.group16_staging_vms_sg.security_group_id
  volume_size                  = 20
  asg_name                     = "group16-staging-asg"
  min_size                     = 1
  max_size                     = 4
  # desired_capacity             = 1
  subnet_ids                   = [module.group16_staging_subnets.subnet_ids[3], module.group16_staging_subnets.subnet_ids[4], module.group16_staging_subnets.subnet_ids[5]]
  instance_tag_name            = "group16-staging-VM+"
  scale_out_policy_name        = "group16-staging-scale-out"
  scale_out_scaling_adjustment = 1
  scale_out_cooldown           = 300
  scale_in_policy_name         = "group16-staging-scale-in"
  scale_in_scaling_adjustment  = -1
  scale_in_cooldown            = 300
  #dim_instance_id              = module.group16_staging_instances.instance_ids[1]
  target_group_arn             = module.group16_staging_load_balancer.target_group_arn
}


#creating staging resources

#creating staging vpc
module "group16_staging_vpc" {
  source               = "/home/ec2-user/environment/terraform-project/modules/vpc"
  vpc_cidr_block       = "10.200.0.0/16"
  vpc_instance_tenancy = "default"
  vpc_name             = "group16-staging-vpc"
}

#creating staging subnets
module "group16_staging_subnets" {
  source             = "/home/ec2-user/environment/terraform-project/modules/subnet"
  subnet_names       = ["group16_staging_public1", "group16_staging_public2", "group16_staging_public3", "group16_staging_private1", "group16_staging_private2", "group16_staging_private3"]
  subnet_cidr_blocks = ["10.200.1.0/24", "10.200.2.0/24", "10.200.3.0/24", "10.200.4.0/24", "10.200.5.0/24", "10.200.6.0/24"]
  availability_zones = ["us-east-1b", "us-east-1c", "us-east-1d", "us-east-1b", "us-east-1c", "us-east-1d"]
  vpc_id             = module.group16_staging_vpc.vpc_id
}

#creating security group for staging bastion host
module "group16_staging_bastion_sg" {
  source                     = "/home/ec2-user/environment/terraform-project/modules/security_group"
  security_group_name        = "group16-staging-security-group_bastion"
  security_group_description = "Security group for staging environment"
  vpc_id                     = module.group16_staging_vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
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



#creating security group for staging bastion host
module "group16_staging_alb_sg" {
  source                     = "/home/ec2-user/environment/terraform-project/modules/security_group"
  security_group_name        = "group16-staging-security-group_alb"
  security_group_description = "Security group for staging environment"
  vpc_id                     = module.group16_staging_vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
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




#creating security group for staging vms

module "group16_staging_vms_sg" {
  source                     = "/home/ec2-user/environment/terraform-project/modules/security_group"
  security_group_name        = "group16-staging-security-group_vm"
  security_group_description = "Security group for staging environment"
  vpc_id                     = module.group16_staging_vpc.vpc_id

  ingress_rules = [
    {
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
      #security_groups = [module.group16_staging_bastion_sg.security_group_id]
    },

    {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
      #security_groups = [module.group16_staging_alb_sg.security_group_id]

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


#creating staging instances
module "group16_staging_instances" {
  source = "/home/ec2-user/environment/terraform-project/modules/instance"

  instances = [
    {
      name              = "group16-staging_bastion"
      ami_id            = "ami-051f8a213df8bc089"
      instance_type     = "t3.small"
      subnet_id         = module.group16_staging_subnets.subnet_ids[0]
      security_group_id = module.group16_staging_alb_sg.security_group_id
      assign_public_ip  = true
      key_name          = aws_key_pair.group16_staging_key_pair.key_name
    },
    {
      name              = "group16-staging_vm"
      ami_id            = "ami-051f8a213df8bc089"
      instance_type     = "t3.small"
      subnet_id         = module.group16_staging_subnets.subnet_ids[4]
      security_group_id = module.group16_staging_vms_sg.security_group_id
      user_data         = file("/home/ec2-user/environment/terraform-project/vm_user_data.sh")
      assign_public_ip  = false
      key_name          = aws_key_pair.group16_staging_key_pair.key_name

    }
  ]
}


#creating staging public route table
module "group16_staging_PublicRT" {
  source = "/home/ec2-user/environment/terraform-project/modules/route_table"

  vpc_id     = module.group16_staging_vpc.vpc_id
  gateway_id = module.group16_staging_internet_gateway.internet_gateway_id
  subnet_id  = module.group16_staging_subnets.subnet_ids[0]
}

#creating staging private route table
module "group16_staging_PrivateRT" {
  source = "/home/ec2-user/environment/terraform-project/modules/route_table"

  vpc_id     = module.group16_staging_vpc.vpc_id
  gateway_id = aws_nat_gateway.nat_gateway.id
  subnet_id  = module.group16_staging_subnets.subnet_ids[3]
}

#creating staging route table asscociation
module "group16_staging_route_table_associations" {
  source = "/home/ec2-user/environment/terraform-project/modules/route_table_association"

  route_table_associations = [
    {
      subnet_id      = module.group16_staging_subnets.subnet_ids[0]
      route_table_id = module.group16_staging_PublicRT.route_table_id
    },
    {
      subnet_id      = module.group16_staging_subnets.subnet_ids[1]
      route_table_id = module.group16_staging_PublicRT.route_table_id
    },
    {
      subnet_id      = module.group16_staging_subnets.subnet_ids[2]
      route_table_id = module.group16_staging_PublicRT.route_table_id
    },
    {
      subnet_id      = module.group16_staging_subnets.subnet_ids[3]
      route_table_id = module.group16_staging_PrivateRT.route_table_id
    },
    {
      subnet_id      = module.group16_staging_subnets.subnet_ids[4]
      route_table_id = module.group16_staging_PrivateRT.route_table_id
    },
    {
      subnet_id      = module.group16_staging_subnets.subnet_ids[5]
      route_table_id = module.group16_staging_PrivateRT.route_table_id
    }

  ]
}


#create load balancer:
# Use the load balancer module
module "group16_staging_load_balancer" {
  source = "/home/ec2-user/environment/terraform-project/modules/loadbalancer"

  alb_name                         = "group16-staging-alb"
  subnet_ids                       = [module.group16_staging_subnets.subnet_ids[0], module.group16_staging_subnets.subnet_ids[1], module.group16_staging_subnets.subnet_ids[2]]
  security_group_id                = module.group16_staging_vms_sg.security_group_id
  enable_deletion_protection       = false
  target_group_name                = "group16-staging-target-group"
  target_group_port                = 80
  vpc_id                           = module.group16_staging_vpc.vpc_id
  health_check_path                = "/"
  health_check_port                = "traffic-port"
  health_check_interval            = 30
  health_check_timeout             = 10
  health_check_healthy_threshold   = 5
  health_check_unhealthy_threshold = 10
  listener_port                    = 80
  listener_rule_priority           = 100
  listener_rule_path               = "/"
  target_id                        = module.group16_staging_instances.instance_ids[1]
}

# Output the DNS name of the created ALB
output "alb_dns_name" {
  value = module.group16_staging_load_balancer.alb_dns_name
}




