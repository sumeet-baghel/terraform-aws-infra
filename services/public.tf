# This is a public service accessible via the Application load balancer from the internet.
# It is recommended to create a route53 domain with a friendly record to access the service.

data "template_file" "public_app_data" {
  template = file("${path.root}/templates/public_app_data")
}

locals {
  public_app_data = data.template_file.public_app_data.rendered
  public_app_name = "public-${var.app_name}"
}

resource "aws_security_group" "app_lb" {
  name   = "${var.namespace}-${local.public_app_name}-lb"
  vpc_id = data.aws_vpc.vpc.id

  ingress {
    description = "Allow HTTP traffic from the internet."
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.common_tags
}

resource "aws_lb" "app_lb" {
  name               = "${var.namespace}-${local.public_app_name}"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.app_lb.id,
    data.aws_security_group.default.id,
  ]
  subnets = data.aws_subnets.public.ids

  enable_deletion_protection = false
  tags                       = local.common_tags
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_lb_target.arn
  }
  tags = local.common_tags
}

resource "aws_lb_target_group" "app_lb_target" {
  name     = "${var.namespace}-${local.public_app_name}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.vpc.id
  tags     = local.common_tags
}

module "public_app" {
  source  = "cloudposse/ec2-autoscale-group/aws"
  version = "0.30.1"

  namespace = var.namespace
  stage     = var.deploy_stage
  name      = local.public_app_name

  image_id                    = data.aws_ami.amzn_ami.id
  instance_type               = var.public_instance_type
  security_group_ids          = [data.aws_security_group.default.id]
  subnet_ids                  = data.aws_subnets.private.ids
  health_check_type           = "EC2"
  min_size                    = var.min_autoscale_instance_count
  max_size                    = var.max_autoscale_instance_count
  wait_for_capacity_timeout   = "2m"
  associate_public_ip_address = false
  user_data_base64            = base64encode(local.public_app_data)
  key_name                    = var.ssh_key_pair

  target_group_arns = [
    aws_lb_target_group.app_lb_target.arn,
  ]

  # Auto-scaling policies and CloudWatch metric alarms
  autoscaling_policies_enabled           = true
  cpu_utilization_high_threshold_percent = var.cpu_autoscale_threshold
  cpu_utilization_low_threshold_percent  = var.cpu_autoscale_recovery_threshold

  tags = merge(local.common_tags,
    {
      "app" = local.public_app_name
    }
  )
}
