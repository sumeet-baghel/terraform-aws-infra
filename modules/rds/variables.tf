variable "region" {
  description = "Region for the AWS provider"
}

variable "name" {
  type        = string
  description = "Name of the Postgres Instance"
}

variable "app" {
  type        = string
  description = "Name of the application with which this DB is associated (for tagging purposes)."
}

variable "deploy_stage" {
  type        = string
  description = "The deploy stage. Usually 'staging' or 'production', but could be 'pre-prod', 'development', etc. for advanced use."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Database specific tags to be assigned to all resources.  Note that additional tags will be added for some resources."
}

variable "pg_replica" {
  type        = bool
  default     = false
  description = "Create Read-only follower (Replica)"
}

variable "pg_termination_protection" {
  type        = bool
  default     = true
  description = "Database Deletion Protection, this should only be changed when the database needs to be deleted."
}

variable "pg_version" {
  type        = string
  default     = 14.2
  description = "PostgreSQL version"
}

variable "pg_admin_username" {
  type        = string
  default     = ""
  description = "Postgres admin user. If not set or set to a blank string, the username will be randomized."
}

variable "pg_db_name" {
  type        = string
  default     = ""
  description = "Postgres database name. If not set or set to a blank string, the database name will be randomized."
}

# Example pg_config:
/*  pg_config = {
      autovacuum_vacuum_cost_delay = -1,
      autovacuum_vacuum_cost_limit = -1,
    }
*/
variable "pg_config" {
  type        = map(any)
  default     = null
  description = "Map of configuration parameters for the underlying postgres instance"
}

variable "backup_retention_period" {
  type        = number
  default     = 7
  description = "The days to retain backups for, can range between 0-35"
}

variable "disk_size_gib" {
  description = "The allocated storage in gibibytes. If Storage Autoscaling is enabled, this variable represents the initial storage allocation"
  type        = number
}

variable "instance_type" {
  description = "The instance type of the RDS instance"
  type        = string
}

variable "instance_type_replica" {
  description = "The instance type of the RDS replica instance"
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "The number of days to retain the log events in the specified db instance cloudwatch loggroup. Defaults to 14 days for production and 7 days for all other stages if 0 is passed. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653."
  type        = number
  default     = 0
}

variable "multi_az" {
  description = "Enable multi-az for the RDS instance."
  type = bool
  default = false
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}
