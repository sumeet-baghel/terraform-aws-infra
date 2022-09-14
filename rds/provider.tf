provider "aws" {
  region = var.aws_region

  # Use a profile to deploy resources in an aws account
  # profile = "default"
}
