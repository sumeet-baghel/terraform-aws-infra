data "aws_vpc" "vpc" {
  # Select VPC based on the tags
  tags = {
    Name        = var.vpc_name,
    environment = var.deploy_stage,
    app         = var.app_name,
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    "subnet/type" = "private"
  }
}
