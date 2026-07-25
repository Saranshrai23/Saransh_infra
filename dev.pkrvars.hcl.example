aws_region = "us-east-1"

# Use your existing OTMS VPC and a PUBLIC subnet that has:
# 1. a route to an Internet Gateway
# 2. public IPv4 assignment enabled, or Packer's public-IP association allowed
vpc_id    = "vpc-087f67f732c5053a4"
subnet_id = "subnet-0612448b4081aee8b"

instance_type   = "t3.small"
root_volume_size = 16
ami_name_prefix = "dev-otms-attendance"

application_repo = "https://github.com/OT-MICROSERVICES/attendance-api.git"
application_ref  = "main"

environment = "dev"
application = "attendance"
owner       = "Infra-Titans"
cost_center = "Snaatak"
