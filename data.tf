data "aws_vpc" "otms" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnet" "database_a" {
  filter {
    name   = "tag:Name"
    values = [var.database_subnet_a_name]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.otms.id]
  }
}

data "aws_subnet" "database_b" {
  filter {
    name   = "tag:Name"
    values = [var.database_subnet_b_name]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.otms.id]
  }
}
