# RDS PostgreSQL Database Module

This module creates the following in RDS

- Postgres Instance Master
- Postgres Instance Replica (optional)

## Inputs to the Module

### Inputs

| Input | Type | Required | Default | Description |
|:------|:----:|:--------:|:-------:|:-------------|
| region| string | Yes | |AWS region to create resources. |
| name| string | Yes | | Name of the Postgres Instance. |
| app| string | Yes | | Name of the application with which this DB is associated (for tagging purposes). |
| multi_az| bool | No | false | Enable multi-az for the RDS instance. |
| vpc_id| string | Yes | | |
| subnet_ids| list(string) | Yes | | |
| deploy_stage| string | Yes | | The deploy stage. Usually 'staging' or 'production', but could be 'pre-prod', 'development', etc. for advanced use. |
| disk_size_gib| number | Yes | | [DB size](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#Concepts.Storage.GeneralSSD) in GiB|
| instance_type | string | Yes | | [Instance type](https://instances.vantage.sh/rds/) , look at [AWS documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html) for more info |
| instance_type_replica | string | No |defaults to instance_type | Instance type of the replica |
| pg_replica | bool | No | `false` | Create Read-only Replica. **Note** all DBs automatically have a hot standby replica in production to handle failovers; `pg_replica` should be set **only** if a separate RO replica is required for managing query performance. |
| pg_version | string | No | `14.2` | PostgreSQL version |
| pg_admin_username | string | No | random string of length 15 | Postgres admin user |
| pg_db_name | string | No | random string of length 15 | Postgres database name |
| pg_config | map | No | [ ] | Map of configuration parameters listed below |
| backup_retention_period | number | No | 7 | The days to retain backups for, can range between 0-35 |
| tags | map | No | { } | Database specific tags to be assigned to all resources |
| pg_termination_protection | bool | No | true | Database Deletion Protection, this should only be changed when the database needs to be deleted. |
| log_retention_days | number | No | 0 | Sets the number of days to retain PostgreSQL logs in the CloudWatch loggroup. Defaults to 14 days for production and 7 days for all other stages if 0 is passed. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653. |

### pg_config

| Config | Type | Required | Default | Description |
|:------|:----:|:--------:|:-------:|-------------|
| idle_in_transaction_session_timeout | string | No | `900` | Idle session timeout in sec |
| log_min_duration_statement | string | No | `2000` | log min duration |

### Secrets Created by the Module

This module creates secrets for `pg_master_connection` and `pg_replica_connection` with the connection values for these fields:

- `pg.db_host` and `pg_replica.db_host`: Host Name
- `pg.db_port` and `pg_replica.db_port`: Port
- `pg.db_name` and `pg_replica.db_name`: DB Name
- `pg.db_admin_user` and `pg_replica.db_admin_user`: Username
- `pg.db_admin_password` and `pg_replica.db_admin_password`: Password

### Deleting Databases

Follow the steps to delete the DB using Terraform:

1. Add `pg_termination_protection = false` input variable to enable deletion of the DB instance.
2. Use `terraform destroy` to delete the database module.
