locals {
  # Add tags that are common across all the resources
  common_tags = {
    "environment" = var.deploy_stage
    "app"         = var.app_name
  }

  az_mapping = {
    0 = "a"
    1 = "b"
    2 = "c"
    3 = "d"
  }
  azs = [for count in range(var.az_count) : "${var.aws_region}${local.az_mapping[count]}"]
}
