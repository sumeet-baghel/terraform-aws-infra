# This is a bastion host to ssh into the private app instance.
# You can modify the security group to allow bastion to access other private resources as well. 

resource "aws_security_group" "bastion" {
  name   = "${var.namespace}-bastion-instance"
  vpc_id = data.aws_vpc.vpc.id

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastion_ingress_cidr]
  }

  egress {
    description = "SSH into a private instance."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.common_tags
}

resource "aws_instance" "bastion_host" {
  ami           = data.aws_ami.amzn_ami.id
  instance_type = var.bastion_instance_type
  vpc_security_group_ids = [aws_security_group.bastion.id,
    data.aws_security_group.default.id,
  ]
  subnet_id                   = data.aws_subnets.public.ids[0]
  associate_public_ip_address = true
  key_name                    = var.ssh_key_pair

  tags = merge(local.common_tags,
    {
      "Name" = "${var.namespace}-bastion"
    }
  )
}
