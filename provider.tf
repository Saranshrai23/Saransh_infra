provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Application = var.application
      Environment = var.environment
      Owner       = var.owner
      CostCenter  = var.cost_center
      ManagedBy   = "Terraform"
    }
  }
}
