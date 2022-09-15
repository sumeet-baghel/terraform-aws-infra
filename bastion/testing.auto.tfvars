aws_region   = "ap-south-1"
vpc_name     = "Test VPC"
deploy_stage = "testing"
app_name     = "nginx-service"
namespace    = "demo"
# For production usage, please use your VPN CIDR range.
# You can test using your own IP address.
bastion_ingress_cidr = "219.91.171.252/32"
ssh_key_pair         = "sbaghel-test-rsa"
