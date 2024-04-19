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
resource "aws_key_pair" "group16_prod_key_pair" {
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
  subnet_id     = module.group16_prod_subnets.subnet_ids[0]

  tags = {
    Name = "group16-prod-nat-gateway"
  }
}

# creating internet gateway
module "group16_prod_internet_gateway" {
  source = "/home/ec2-user/environment/terraform-project/modules/internet_gateway"
  vpc_id = module.group16_prod_vpc.vpc_id
}


module "group16_prod_asg" {
  source = "/home/ec2-user/environment/terraform-project/modules/autoscaling"

  instance_id                  = module.group16_prod_instances.instance_ids[1]
  ami_name                     = "group16-prod-ami"
  ami_tag_name                 = "group16-prod-ami"
  launch_template_name         = "group16_prod_lt"
  instance_type                = "t3.medium"
  key_name                     = aws_key_pair.group16_prod_key_pair.key_name
  security_group_id            = module.group16_prod_vms_sg.security_group_id
  volume_size                  = 20
  asg_name                     = "group16-prod-asg"
  min_size                     = 1
  max_size                     = 4
  # desired_capacity             = 1
  subnet_ids                   = [module.group16_prod_subnets.subnet_ids[3], module.group16_prod_subnets.subnet_ids[4], module.group16_prod_subnets.subnet_ids[5]]
  instance_tag_name            = "group16-prod-VM+"
  scale_out_policy_name        = "group16-prod-scale-out"
  scale_out_scaling_adjustment = 1
  scale_out_cooldown           = 300
  scale_in_policy_name         = "group16-prod-scale-in"
  scale_in_scaling_adjustment  = -1
  scale_in_cooldown            = 300
  dim_instance_id              = module.group16_prod_instances.instance_ids[1]
  target_group_arn             = module.group16_prod_load_balancer.target_group_arn
}


#creating prod resources

#creating prod vpc
module "group16_prod_vpc" {
  source               = "/home/ec2-user/environment/terraform-project/modules/vpc"
  vpc_cidr_block       = "10.250.0.0/16"
  vpc_instance_tenancy = "default"
  vpc_name             = "group16-prod-vpc"
}

#creating prod subnets
module "group16_prod_subnets" {
  source             = "/home/ec2-user/environment/terraform-project/modules/subnet"
  subnet_names       = ["group16_prod_public1", "group16_prod_public2", "group16_prod_public3", "group16_prod_private1", "group16_prod_private2", "group16_prod_private3"]
  subnet_cidr_blocks = ["10.250.1.0/24", "10.250.2.0/24", "10.250.3.0/24", "10.250.4.0/24", "10.250.5.0/24", "10.250.6.0/24"]
  availability_zones = ["us-east-1b", "us-east-1c", "us-east-1d", "us-east-1b", "us-east-1c", "us-east-1d"]
  vpc_id             = module.group16_prod_vpc.vpc_id
}

#creating security group for prod bastion host
module "group16_prod_bastion_sg" {
  source                     = "/home/ec2-user/environment/terraform-project/modules/security_group"
  security_group_name        = "group16-prod-security-group_bastion"
  security_group_description = "Security group for prod environment"
  vpc_id                     = module.group16_prod_vpc.vpc_id

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



#creating security group for prod bastion host
module "group16_prod_alb_sg" {
  source                     = "/home/ec2-user/environment/terraform-project/modules/security_group"
  security_group_name        = "group16-prod-security-group_alb"
  security_group_description = "Security group for prod environment"
  vpc_id                     = module.group16_prod_vpc.vpc_id

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


#creating security group for prod vms

module "group16_prod_vms_sg" {
  source                     = "/home/ec2-user/environment/terraform-project/modules/security_group"
  security_group_name        = "group16-prod-security-group_vm"
  security_group_description = "Security group for prod environment"
  vpc_id                     = module.group16_prod_vpc.vpc_id

  ingress_rules = [
    {
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
      #security_groups = [module.group16_prod_bastion_sg.security_group_id]
    },

    {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
      #security_groups = [module.group16_prod_alb_sg.security_group_id]

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
module "group16_prod_instances" {
  source = "/home/ec2-user/environment/terraform-project/modules/instance"

  instances = [
    {
      name              = "group16-prod_bastion"
      ami_id            = "ami-051f8a213df8bc089"
      instance_type     = "t3.medium"
      subnet_id         = module.group16_prod_subnets.subnet_ids[0]
      security_group_id = module.group16_prod_alb_sg.security_group_id
      assign_public_ip  = true
      key_name          = aws_key_pair.group16_prod_key_pair.key_name
    },
    {
      name              = "group16-prod_vm"
      ami_id            = "ami-051f8a213df8bc089"
      instance_type     = "t3.medium"
      subnet_id         = module.group16_prod_subnets.subnet_ids[4]
      security_group_id = module.group16_prod_vms_sg.security_group_id
      user_data         = file("/home/ec2-user/environment/terraform-project/vm_user_data.sh")
      assign_public_ip  = false
      key_name          = aws_key_pair.group16_prod_key_pair.key_name

    }
  ]
}


#creating prod public route table
module "group16_prod_PublicRT" {
  source = "/home/ec2-user/environment/terraform-project/modules/route_table"

  vpc_id     = module.group16_prod_vpc.vpc_id
  gateway_id = module.group16_prod_internet_gateway.internet_gateway_id
  subnet_id  = module.group16_prod_subnets.subnet_ids[0]
}

#creating prod private route table
module "group16_prod_PrivateRT" {
  source = "/home/ec2-user/environment/terraform-project/modules/route_table"

  vpc_id     = module.group16_prod_vpc.vpc_id
  gateway_id = aws_nat_gateway.nat_gateway.id
  subnet_id  = module.group16_prod_subnets.subnet_ids[3]
}

#creating prod route table asscociation
module "group16_prod_route_table_associations" {
  source = "/home/ec2-user/environment/terraform-project/modules/route_table_association"

  route_table_associations = [
    {
      subnet_id      = module.group16_prod_subnets.subnet_ids[0]
      route_table_id = module.group16_prod_PublicRT.route_table_id
    },
    {
      subnet_id      = module.group16_prod_subnets.subnet_ids[1]
      route_table_id = module.group16_prod_PublicRT.route_table_id
    },
    {
      subnet_id      = module.group16_prod_subnets.subnet_ids[2]
      route_table_id = module.group16_prod_PublicRT.route_table_id
    },
    {
      subnet_id      = module.group16_prod_subnets.subnet_ids[3]
      route_table_id = module.group16_prod_PrivateRT.route_table_id
    },
    {
      subnet_id      = module.group16_prod_subnets.subnet_ids[4]
      route_table_id = module.group16_prod_PrivateRT.route_table_id
    },
    {
      subnet_id      = module.group16_prod_subnets.subnet_ids[5]
      route_table_id = module.group16_prod_PrivateRT.route_table_id
    }

  ]
}


#create load balancer:
#Use the load balancer module
module "group16_prod_load_balancer" {
  source = "/home/ec2-user/environment/terraform-project/modules/loadbalancer"

  alb_name                         = "group16-prod-alb"
  subnet_ids                       = [module.group16_prod_subnets.subnet_ids[0], module.group16_prod_subnets.subnet_ids[1], module.group16_prod_subnets.subnet_ids[2]]
  security_group_id                = module.group16_prod_vms_sg.security_group_id
  enable_deletion_protection       = false
  target_group_name                = "group16-prod-target-group"
  target_group_port                = 80
  vpc_id                           = module.group16_prod_vpc.vpc_id
  # health_check_path                = "/"
  # health_check_port                = "traffic-port"
  # health_check_interval            = 30
  # health_check_timeout             = 10
  # health_check_healthy_threshold   = 5
  # health_check_unhealthy_threshold = 10
  listener_port                    = 80
  listener_rule_priority           = 100
  listener_rule_path               = "/"
  #target_id                        = module.group16_prod_instances.instance_ids[1]
}

# Output the DNS name of the created ALB
output "alb_dns_name" {
  value = module.group16_prod_load_balancer.alb_dns_name
}




