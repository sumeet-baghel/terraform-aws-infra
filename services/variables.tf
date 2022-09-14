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

variable "public_instance_type" {
  type        = string
  description = "Instance type to be used for the public app. Defaults to the free tier instance."
  default     = "t2.micro"
}

variable "private_instance_type" {
  type        = string
  description = "Instance type to be used for the private app. Defaults to the free tier instance."
  default     = "t2.micro"
}

variable "cpu_autoscale_threshold" {
  type        = number
  description = "Percentage threshold to autoscale the CPU."
  default     = 80
}

variable "cpu_autoscale_recovery_threshold" {
  type        = number
  description = "Percentage threshold to downscale based on the CPU."
  default     = 40
}

variable "min_autoscale_instance_count" {
  type        = number
  description = "Minimum number of instances to start."
  default     = 1
}

variable "max_autoscale_instance_count" {
  type        = number
  description = "Maximum number of instances that the autoscaler can create."
  default     = 3
}

variable "ssh_key_pair" {
  type        = string
  description = "A key pair to SSH into the app instances and bastion."
}
