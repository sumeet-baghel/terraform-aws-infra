# Hosting public and private application services on AWS

This repository contains terraform required to deploy scalable and available infra using the following AWS services.

- Networking components: VPC, Subnets, NAT Gateways, Route tables, etc.
- EC2 instances to host container applications controlled by Autoscaling groups.
- A Bastion host to ssh into the private instances.
- Cloudwatch alarms that trigger the autoscaling policy based on the cloudwatch metrics.
- Application Load Balancer to serve traffic for the public apps.
- An RDS instance that can be used by applications.

## Architectural Diagram

![image](https://user-images.githubusercontent.com/62604696/190321794-3749ab98-f07d-467e-9536-3835ba2b5eb5.png)

## Terraform

### Modules

I've created a VPC module, wrapped the RDS module provided by AWS, and used an awesome module that provides all the cloudwatch and autoscaling magic.

**VPC Module**

I've tried to keep it flexible and minimal so that it can be used wherever there's a need to create a VPC. It takes inputs such as VPC name, CIDR range, AZs, and tags.

For more information, please go through the [readme](https://github.com/sumeet-baghel/terraform-aws-infra/tree/main/modules/vpc).

**RDS Module**

RDS has a ton of options exposed in the [AWS module](https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/latest). I've created a wrapper around it to avoid the creation of SGs, Cloudwatch log groups, and other resources every time.

The wrapper provides helpful features such as a boolean input to enable or disable replicas and store the master and replica credentials in the AWS secrets manager. The secrets manager's secret names are available as an output.

For more information, please go through the [readme](https://github.com/sumeet-baghel/terraform-aws-infra/tree/main/modules/rds).

**Awesome EC2 Autoscaling Module**

This is a perfect module by [Cloudposse](https://github.com/cloudposse) that provides Autoscaling Groups, templates, policies, and cloudwatch alarms and takes away the hassle of managing all that terraform.

For more information, please go through the [module doc](https://registry.terraform.io/modules/cloudposse/ec2-autoscale-group/aws/0.30.1).

### Example usage

The repository consists of the following terraform directories.

- **/bastion:** This creates a Bastion host used to ssh into the private instances.
- **/modules:** Contains the RDS and VPC modules.
- **/rds:** Example usage of the RDS module to create an RDS instance.
- **/services:** Example usage of the Cloudposse module to create public and private services.
- **/vpc:** Example usage of the VPC module.    

### Deploy and test?

You can use the examples provided in the repository, modify them as per your requirement and deploy the terraform.

**Important Notes:**
- Unfortunately, M1 mac doesn't support some of the terraform providers used in this terraform so I tested and developed this in a container with terraform version `0.14.11`. If you're using the latest version of terraform, you might experience some minor while applying the terraform.
- The public and private services are hosting a sample nginx service included in the userdata scripts.
- Provide the desired AWS profile in `provider.tf` file present in the modules and some other directories before running the terraform.
- Go through the `variables.tf`, and `testing.auto.tfvars` files to change the inputs as per your requirement.
- [Create a Key Pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html) to SSH into the private instances via the bastion host.



**Deployment steps**

- **Create the VPC**

    ```console
    cd vpc/

    terraform init

    terraform apply
    ```

    Verify the resource creation in the AWS console.

- **Create public and private services**
     
    ```console
    cd ../services/
    
    terraform init

    terraform apply
    ```
    
    The terraform should output a Public DNS to test the public service. 

- **Create the bastion host**

   ```console
   cd ../bastion/
   
   terraform init

   terraform apply
   ```
   
   Terraform should output the Public IP of the Bastion host.
   
   **Verify the bastion connectivity and ssh access to the private instance**
   
   ```console
   ssh -A -i "public_key.pem" ec2-user@<bastion-public-ip>

   ssh ec2-user@<private-service-instance-ip>
   ```

   Using the above commands, you should be able to ssh into the service instances hosted in the private subnets.
  
   For more information on SSH forwarding, please go through this [AWS blog](https://aws.amazon.com/blogs/security/securely-connect-to-linux-instances-running-in-a-private-amazon-vpc/).

- **Create an RDS instance**

  ```console
  cd ../rds/
  
  terraform init

  terraform apply
  ```

  Terraform should output the secrets manager secret containing the DB credentials. Since the DB is using private subnets, it isn't accessible directly from the internet. If you want to access the DB, you can modify the bastion host and its security group to do that or use a VPN CIDR range instead.
