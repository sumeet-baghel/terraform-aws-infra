locals {
  pg_master_connection = {
    db_endpoint       = module.master.db_instance_endpoint
    db_name           = module.master.db_instance_name
    db_port           = module.master.db_instance_port
    db_admin_user     = module.master.db_instance_username
    db_admin_password = module.master.db_instance_password
  }
  # Note - we expect to have exactly 1 replica if a replica exists, so we reference module.replica[0] without any concern.
  pg_replica_connection = var.pg_replica ? {
    db_endpoint       = module.replica[0].db_instance_endpoint
    db_name           = module.replica[0].db_instance_name
    db_port           = module.replica[0].db_instance_port
    db_admin_user     = module.replica[0].db_instance_username
    db_admin_password = module.master.db_instance_password
  } : {}
}

resource "aws_secretsmanager_secret" "pg_master_connection" {
  # Secrets must be stored in a path specifying the relevant application/service.
  name                    = "/rds/${var.deploy_stage}/${var.app}/${module.master.db_instance_id}/pg_master_connection"
  recovery_window_in_days = 0
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "pg_master_connection" {
  secret_id     = aws_secretsmanager_secret.pg_master_connection.name
  secret_string = jsonencode(local.pg_master_connection)
}

resource "aws_secretsmanager_secret" "pg_replica_connection" {
  count = var.pg_replica ? 1 : 0
  # Secrets must be stored in a path specifying the relevant application/service.
  name                    = "/rds/${var.deploy_stage}/${var.app}/${module.replica[0].db_instance_id}/pg_replica_connection"
  recovery_window_in_days = 0
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "pg_replica_connection" {
  count         = var.pg_replica ? 1 : 0
  secret_id     = aws_secretsmanager_secret.pg_replica_connection[0].name
  secret_string = jsonencode(local.pg_replica_connection)
}
