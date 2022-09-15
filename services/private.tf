# This can be assumed as a private worker service that might be interacting
# with other AWS services such as RDS, Redis, etc., in the private VPC.

# NOTE: Autoscaling is based purely on CPU utilization in this terraform.
# You can also use memory and other custom cloudwatch metrics to autoscale.

data "template_file" "private_app_data" {
  template = file("${path.root}/templates/private_app_data")
}

locals {
  private_app_data = data.template_file.private_app_data.rendered
  private_app_name = "private-${var.app_name}"
}

# https://registry.terraform.io/modules/cloudposse/ec2-autoscale-group/aws/0.30.1
module "private_app" {
  source  = "cloudposse/ec2-autoscale-group/aws"
  version = "0.30.1"

  namespace = var.namespace
  stage     = var.deploy_stage
  name      = local.private_app_name

  image_id                    = data.aws_ami.amzn_ami.id
  instance_type               = var.private_instance_type
  security_group_ids          = [data.aws_security_group.default.id]
  subnet_ids                  = data.aws_subnets.private.ids
  health_check_type           = "EC2"
  min_size                    = var.min_autoscale_instance_count
  max_size                    = var.max_autoscale_instance_count
  wait_for_capacity_timeout   = "2m"
  associate_public_ip_address = false
  user_data_base64            = base64encode(local.private_app_data)
  key_name                    = var.ssh_key_pair

  # Auto-scaling policies and CloudWatch metric alarms
  autoscaling_policies_enabled           = true
  cpu_utilization_high_threshold_percent = var.cpu_autoscale_threshold
  cpu_utilization_low_threshold_percent  = var.cpu_autoscale_recovery_threshold

  tags = merge(local.common_tags,
    {
      "app" = local.private_app_name
    }
  )
}
