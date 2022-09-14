variable "aws_region" {
  type        = string
  description = "AWS region to create the infrastructure."
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC."
}

variable "deploy_stage" {
  type        = string
  description = "Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'."
}

variable "app_name" {
  type        = string
  description = "Name of the application or solution."
}

variable "namespace" {
  type        = string
  description = "ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique."
}

variable "bastion_instance_type" {
  type        = string
  description = "Instance type to be used for the bastion host. Defaults to the free tier instance."
  default     = "t2.micro"
}

variable "bastion_ingress_cidr" {
  type        = string
  description = "CIDR range to allow bastion access. Ideally, this should be your org's VPN cidr range."
}

variable "ssh_key_pair" {
  type        = string
  description = "A key pair to SSH into the app instances and bastion."
}
