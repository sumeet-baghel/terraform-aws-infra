locals {
  master_identifier   = var.name
  replica_identifier  = "${var.name}-replica"
  pg_replica_instance = var.instance_type_replica == null ? var.instance_type : var.instance_type_replica
  pg_admin_username   = var.pg_admin_username == "" ? random_string.admin_user.result : var.pg_admin_username
  pg_db_name          = var.pg_db_name == "" ? random_string.db_name.result : var.pg_db_name

  override_pg_config = {
    "rds.force_ssl" = 1
  }

  # Reference https://aws.amazon.com/blogs/database/best-practices-for-amazon-rds-postgresql-replication/
  override_replica_pg_config = merge(
    local.override_pg_config,
    {
      "hot_standby_feedback" = 1
    },
  )

  # Postgres config
  final_pg_config         = [for k, v in merge(var.pg_config, local.override_pg_config) : { name = k, value = v }]
  final_pg_replica_config = [for k, v in merge(var.pg_config, local.override_replica_pg_config) : { name = k, value = v }]

  pg_major_version = split(".", var.pg_version)[0]

  cloudwatch_log_retention_days = var.log_retention_days == 0 ? (var.deploy_stage == "production" ? 14 : 7) : var.log_retention_days
}
