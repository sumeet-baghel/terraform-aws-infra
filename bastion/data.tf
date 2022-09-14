# Using the most recent Amazon AMI for simplicity without any update strategy.
# In a production env, it is recommended to have some auto-update strategy in place. 

data "aws_ami" "amzn_ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["amazon"]
}

data "aws_vpc" "vpc" {
  # Select VPC based on the tags
  tags = {
    Name        = var.vpc_name,
    environment = var.deploy_stage,
    app         = var.app_name,
  }
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.vpc.id
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    "subnet/type" = "public"
  }
}
