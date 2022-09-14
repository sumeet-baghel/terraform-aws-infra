## VPC module

Creates a VPC with flexible requirement.

### Module Inputs

| Input | Type | Required | Default | Description |
|:------|:----:|:--------:|:-------:|:-------------|
| region| string | Yes | |AWS region to create resources. |
| vpc_name| string | Yes | | Name of the VPC. |
| vpc_cidr| string | Yes | | The CIDR range of the VPC. |
| availability_zones| list(string) | Yes | | List of AZs, e.g., ["us-east-1a", "us-east-1b"]. |
| additional_vpc_tags| map(string) | No | | Additional tags to attach to the VPC. |
| additional_private_subnet_tags| map(string) | No | | Additional tags to attach to the private subnets. |
| additional_public_subnet_tags| map(string) | No | | Additional tags to attach to the public subnets. |

### Destroy resources

Use `terraform destroy` to cleanup.
