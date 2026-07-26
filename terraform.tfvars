aws_region = "us-east-1"

# Attendance API AMI created using Packer
ami_id = "ami-0dd8892eb4b602801"

common_tags = {
  Application = "otms"
  Owner       = "Infra-Titans"
  Environment = "dev"
  CostCenter  = "Snaatak"
  ManagedBy   = "Terraform"
}
