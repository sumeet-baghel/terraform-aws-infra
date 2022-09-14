# Random admin_username generator, only used if var.pg_admin_username is blank
resource "random_string" "admin_user" {
  length    = 15
  special   = false
  numeric    = false
  min_upper = 0
  # Preventing this from changing as it would recreate the DB instance
  lifecycle {
    # don't change an existing username if length/etc requirements change in the future
    ignore_changes = all
  }
}

# Random db_name generator, only used if var.pg_db_name is blank
resource "random_string" "db_name" {
  length    = 15
  special   = false
  numeric    = false
  min_upper = 0
  # Preventing this from changing as it would recreate the DB instance
  lifecycle {
    # don't change an existing db name if length/etc requirements change in the future
    ignore_changes = all
  }
}

# Security group for accessing the database
resource "aws_security_group" "db_access" {
  name        = "${local.master_identifier}-db-access"
  description = "Allow Inbound traffic for the DB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.master_identifier}-db-access"
  })
}

# The terraform RDS module we are using doesn't allow us to configure cloudwatch log group parameters through the module input configuration.
# By default, it would never delete any logs.
# To save costs we want to control the log retention configuration.
resource "aws_cloudwatch_log_group" "rds_cloudwatch_loggroup_master" {
  name              = "/aws/rds/instance/${local.master_identifier}/postgresql"
  retention_in_days = local.cloudwatch_log_retention_days
  tags = var.tags
}

resource "aws_cloudwatch_log_group" "rds_cloudwatch_loggroup_replica" {
  count             = var.pg_replica ? 1 : 0
  name              = "/aws/rds/instance/${local.replica_identifier}/postgresql"
  retention_in_days = local.cloudwatch_log_retention_days
  tags = var.tags
}

# RDS module -> https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/latest
module "master" {
  depends_on = [aws_cloudwatch_log_group.rds_cloudwatch_loggroup_master]
  source     = "terraform-aws-modules/rds/aws"
  version    = "~> 4.5.0"

  identifier = local.master_identifier

  engine                = "postgres"
  engine_version        = var.pg_version
  instance_class        = var.instance_type
  allocated_storage     = var.disk_size_gib
  storage_type          = "gp2"

  db_name                = local.pg_db_name
  username               = local.pg_admin_username
  create_random_password = true
  random_password_length = 10
  port                   = "5432"

  # Valid values (depending on engine): alert, audit, error, general, listener, slowquery, trace, postgresql
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  vpc_security_group_ids = [aws_security_group.db_access.id]

  # The window to perform maintenance in (UTC).
  maintenance_window = "Sat:11:00-Sat:15:00"

  # The daily time range (in UTC) during which automated backups are created if they are enabled.
  backup_window = "00:00-02:00"

  # Specifies whether the DB instance is encrypted
  storage_encrypted = true

  # The days to retain backups for
  backup_retention_period = var.backup_retention_period

  # Specifies if the RDS instance is multi-AZ -- https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html
  # Creates a failover instance in another AZ, that AWS manages and isn't visible to us
  # AWS manages failingover to it in different scenarios and failovers are invisible to us, except via configuring AWS events or querying the status of the RDS instance.
  multi_az = var.multi_az

  # A mapping of tags to assign to all resources
  tags = merge(
    var.tags,
    {
      type = "primary",
      Name = local.master_identifier
  })

  # Create Subnet Group
  create_db_subnet_group = true

  # DB subnet group
  subnet_ids = var.subnet_ids

  # DB parameter group
  family = "postgres${local.pg_major_version}"

  # Disable creation of option group - provide an option group or default AWS default
  create_db_option_group = false

  # Database deletion protection
  deletion_protection = var.pg_termination_protection

  # Specifies whether any database modifications are applied immediately, or during the next maintenance window
  apply_immediately = true

  # The name of the final DB snapshot when this DB instance is deleted.
  final_snapshot_identifier_prefix = "final-snapshot"

  # Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created.
  # If false is specified, a DB snapshot is created before the DB instance is deleted, using the value from final_snapshot_identifier
  skip_final_snapshot = false

  # On delete, copy all Instance tags to the final snapshot (if final_snapshot_identifier is specified)
  copy_tags_to_snapshot = true

  # A list of maps specifying DB parameters to apply
  parameters = local.final_pg_config

  # Specifies whether to remove automated backups immediately after the DB instance is deleted
  delete_automated_backups = false

  # Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window
  auto_minor_version_upgrade = false
}

# This is specifically a read only replica and should be created if a read replica is required for splitting some read transactions away from the primary for performance reasons
# This is not to be used as a failover, unless there is a specific use case for that type of usage
module "replica" {
  depends_on = [module.master, aws_cloudwatch_log_group.rds_cloudwatch_loggroup_replica]
  count      = var.pg_replica == true ? 1 : 0
  source     = "terraform-aws-modules/rds/aws"
  version    = "~> 4.5.0"

  identifier = local.replica_identifier

  engine_version        = var.pg_version
  instance_class        = local.pg_replica_instance
  allocated_storage     = var.disk_size_gib
  storage_type          = "gp2"

  # We don't need to set username and password for replica
  username               = null
  create_random_password = false
  port                   = "5432"

  # Valid values (depending on engine): alert, audit, error, general, listener, slowquery, trace, postgresql
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  vpc_security_group_ids = [aws_security_group.db_access.id]

  maintenance_window = "Sat:11:00-Sat:15:00"
  backup_window      = "00:00-02:00"

  # Specifies whether the DB instance is encrypted
  storage_encrypted = true

  # A mapping of tags to assign to all resources
  tags = merge(
    var.tags,
    {
      type = "replica",
      Name = local.replica_identifier
  })

  # Create Subnet Group
  create_db_subnet_group = false

  # DB subnet group
  subnet_ids = var.subnet_ids

  # DB parameter group
  family = "postgres${local.pg_major_version}"

  # Specifies if the RDS instance has a multi-AZ failover configured, not required for a read replica.
  multi_az = false

  # Disable creation of option group - provide an option group or default AWS default
  create_db_option_group = false

  # Specifies that this resource is a Replica database, and to use this value as the source database.
  replicate_source_db = local.master_identifier

  # Database Deletion Protection
  deletion_protection = var.pg_termination_protection

  # The name of the final DB snapshot when this DB instance is deleted.
  final_snapshot_identifier_prefix = null

  # Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created.
  # If false is specified, a DB snapshot is created before the DB instance is deleted, using the value from final_snapshot_identifier
  skip_final_snapshot = true

  # Specifies whether any database modifications are applied immediately, or during the next maintenance window
  apply_immediately = true

  # A list of maps specifying DB parameters to apply
  parameters = local.final_pg_replica_config

  # Specifies whether to remove automated backups immediately after the DB instance is deleted
  delete_automated_backups = true

  # Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window
  auto_minor_version_upgrade = false
}
