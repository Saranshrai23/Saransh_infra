packer {
  required_version = ">= 1.10.0"

  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.3.0, < 2.0.0"
    }
  }
}

variable "aws_region" {
  type        = string
  description = "AWS region in which Packer will build the Attendance AMI."
  default     = "us-east-1"
}

variable "vpc_id" {
  type        = string
  description = "Existing VPC ID used by the temporary Packer build instance."
}

variable "subnet_id" {
  type        = string
  description = "Existing PUBLIC subnet ID with internet access for package and GitHub downloads."
}

variable "instance_type" {
  type        = string
  description = "Temporary EC2 instance type used during the AMI build."
  default     = "t3.small"
}

variable "root_volume_size" {
  type        = number
  description = "Encrypted gp3 root volume size in GiB."
  default     = 16
}

variable "ami_name_prefix" {
  type        = string
  description = "Prefix used for the generated AMI name."
  default     = "dev-otms-attendance"
}

variable "application_repo" {
  type        = string
  description = "Attendance API Git repository."
  default     = "https://github.com/OT-MICROSERVICES/attendance-api.git"
}

variable "application_ref" {
  type        = string
  description = "Git branch or tag to bake into the AMI."
  default     = "main"
}

variable "poetry_version" {
  type        = string
  description = "Poetry version installed into the image."
  default     = "1.8.5"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment tag."
}

variable "application" {
  type        = string
  default     = "attendance"
  description = "Application tag."
}

variable "owner" {
  type        = string
  default     = "Infra-Titans"
  description = "Owner tag."
}

variable "cost_center" {
  type        = string
  default     = "Snaatak"
  description = "CostCenter tag."
}

locals {
  build_timestamp = formatdate("YYYYMMDD-hhmmss", timestamp())
  ami_name        = "${var.ami_name_prefix}-${local.build_timestamp}"
}

source "amazon-ebs" "attendance" {
  region        = var.aws_region
  vpc_id        = var.vpc_id
  subnet_id     = var.subnet_id
  instance_type = var.instance_type

  associate_public_ip_address = true
  ssh_interface               = "public_ip"
  ssh_username                = "ubuntu"
  ssh_timeout                 = "20m"

  ami_name        = local.ami_name
  ami_description = "OTMS Attendance API AMI with Python 3.11, Poetry, Gunicorn, local Redis and external PostgreSQL support"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture        = "x86_64"
    }
    owners      = ["099720109477"]
    most_recent = true
  }

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    delete_on_termination = true
    encrypted             = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Name        = local.ami_name
    Application = var.application
    Environment = var.environment
    Owner       = var.owner
    CostCenter  = var.cost_center
    ManagedBy   = "Packer"
    Service     = "attendance-api"
    OS          = "Ubuntu-22.04"
  }
}

build {
  name    = "attendance-api-ami"
  sources = ["source.amazon-ebs.attendance"]

  provisioner "shell" {
    script = "scripts/install-attendance.sh"

    environment_vars = [
      "APP_REPO=${var.application_repo}",
      "APP_REF=${var.application_ref}",
      "POETRY_VERSION=${var.poetry_version}"
    ]

    execute_command  = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E bash '{{ .Path }}'"
    expect_disconnect = false
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}
