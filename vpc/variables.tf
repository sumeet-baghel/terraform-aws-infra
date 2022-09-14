variable "aws_region" {
  type        = string
  description = "AWS region to create the infrastructure."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR range for the VPC."
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC."
}

variable "az_count" {
  type        = number
  description = "Number of availability zones to be created."
}

variable "deploy_stage" {
  type        = string
  description = "Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'."
}

variable "app_name" {
  type        = string
  description = "Name of the application or solution."
}

variable "terraform_gitpath" {
  type        = string
  description = "GitHub path where the terraform exists, e.g., 'organization/repository/path/to/terraform/'"
}
