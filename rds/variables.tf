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

variable "pg_name" {
  type        = string
  description = "Name of the RDS instance."
}

variable "rds_master_instance_type" {
  type        = string
  description = "Instance type to be used for the RDS master. Default to the free tier instance."
  default     = "db.t3.micro"
}

variable "rds_replica_instance_type" {
  type        = string
  description = "Instance type to be used for RDS replica. Default to the free tier instance."
  default     = "db.t3.micro"
}

variable "rds_disk_size" {
  type        = number
  description = "Disk storage in GiB for the RDS instance. Defaults to 100 GiB."
  default     = 100
}

variable "create_read_replica" {
  type        = bool
  description = "Create a read replica for the RDS instance."
  default     = false
}

variable "rds_multi_az" {
  type        = bool
  description = "Enable Multi-AZ to failover."
  default     = true
}

variable "postgres_version" {
  type        = string
  description = "Postgres version to be used."
}
