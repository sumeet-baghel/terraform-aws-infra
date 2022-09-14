locals {
  # Add tags that are common across all the resources
  common_tags = {
    "environment" = var.deploy_stage
    "app"         = var.app_name
  }
}