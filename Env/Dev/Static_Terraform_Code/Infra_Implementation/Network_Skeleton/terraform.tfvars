aws_region = "us-east-1"

environment = "dev"
application = "otms"

owner       = "Infra-Titans"
cost_center = "Snaatak"

# Existing ALB created by the separate ALB Terraform project
alb_name = "dev-otms-alb"

# New Route 53 public hosted zone
hosted_zone_name = "saransh.shop"

# New DNS record pointing to the existing ALB
domain_name = "www.saransh.shop"

vpc_cidr  = "10.0.0.0/24"
vpc_name  = "dev-otms-vpc"
