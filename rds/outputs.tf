output "master_db_secret_name" {
  value = module.private_db.master_db_secret_name
}

output "replica_db_secret_name" {
  value = module.private_db.replica_db_secret_name
}
