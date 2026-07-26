data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "otms-terraform-state-dev"
    key    = "network/full.tfstate"
    region = "us-east-1"
  }
}

data "aws_vpc" "main" {
  id = data.terraform_remote_state.network.outputs.vpc_id
}

data "aws_route53_zone" "private" {
  name         = "otms.internal"
  private_zone = true
}
