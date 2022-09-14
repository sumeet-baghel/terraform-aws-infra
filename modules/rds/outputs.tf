output "master_db_secret_name" {
  value = aws_secretsmanager_secret.pg_master_connection.name
}

output "replica_db_secret_name" {
  value = var.pg_replica ? aws_secretsmanager_secret.pg_replica_connection[0].name : ""
}
