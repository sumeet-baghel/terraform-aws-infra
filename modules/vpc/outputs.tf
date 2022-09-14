# Vpc info to be used for peering
output "vpc_config" {
  value = {
    vpc_id     = aws_vpc.vpc.id
    cidr_block = aws_vpc.vpc.cidr_block
    vpc_name   = aws_vpc.vpc.tags["Name"]
    default_sg_id = aws_vpc.vpc.default_security_group_id
    public_subnets = [for count, az in var.availability_zones: aws_subnet.public[count].id]
    private_subnets = [for count, az in var.availability_zones: aws_subnet.private[count].id]
  }
}
