module "vpc" {
  source             = "../modules/vpc"
  vpc_cidr           = var.vpc_cidr
  vpc_name           = var.vpc_name
  availability_zones = local.azs
  region             = var.aws_region

  # Tags to be added to the VPC
  additional_vpc_tags = local.common_tags
  # Tags to be added to the private subnets
  additional_private_subnet_tags = local.common_tags
  # Tags to be added to the public subnets
  additional_public_subnet_tags = local.common_tags
}
