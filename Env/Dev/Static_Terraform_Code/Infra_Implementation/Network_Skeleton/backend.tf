terraform {
  backend "s3" {
    bucket       = "otms-terraform-state-dev-788572613316"
    key          = "network/igw.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
