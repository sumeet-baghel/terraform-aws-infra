module "private_db" {
  source                = "../modules/rds"
  name                  = var.pg_name
  app                   = var.app_name
  region                = var.aws_region
  instance_type         = var.rds_master_instance_type
  instance_type_replica = var.rds_replica_instance_type
  disk_size_gib         = var.rds_disk_size
  multi_az              = var.rds_multi_az
  deploy_stage          = var.deploy_stage
  pg_replica            = var.create_read_replica
  pg_version            = var.postgres_version
  vpc_id                = data.aws_vpc.vpc.id
  subnet_ids            = data.aws_subnets.private.ids
  tags                  = local.common_tags
}
