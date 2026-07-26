terraform {
  backend "s3" {
    bucket = "otms-terraform-state-dev"
    key    = "attendance/asg_policy.tfstate"
    region = "us-east-1"
  }
}
