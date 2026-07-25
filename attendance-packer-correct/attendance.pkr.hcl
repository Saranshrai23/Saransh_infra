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
  description = "AWS region in which the Attendance AMI will be created."
  default     = "us-east-1"
}

variable "vpc_id" {
  type        = string
  description = "Existing VPC used by the temporary Packer builder instance."
}

variable "subnet_id" {
  type        = string
  description = "Public subnet used by the temporary Packer builder instance."
}

variable "instance_type" {
  type        = string
  description = "Temporary EC2 instance type used during the Packer build."
  default     = "t3.micro"
}

variable "app_repo" {
  type        = string
  description = "Attendance API Git repository."
  default     = "https://github.com/OT-MICROSERVICES/attendance-api.git"
}

variable "app_ref" {
  type        = string
  description = "Git branch or tag to bake into the AMI."
  default     = "main"
}

variable "poetry_version" {
  type        = string
  description = "Poetry version installed in the AMI."
  default     = "1.8.5"
}

variable "ami_name_prefix" {
  type        = string
  description = "Prefix used for the generated AMI name."
  default     = "dev-otms-attendance"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "application" {
  type    = string
  default = "otms"
}

variable "owner" {
  type    = string
  default = "Infra-Titans"
}

variable "cost_center" {
  type    = string
  default = "Snaatak"
}

source "amazon-ebs" "attendance" {
  region        = var.aws_region
  instance_type = var.instance_type
  ssh_username  = "ubuntu"

  vpc_id    = var.vpc_id
  subnet_id = var.subnet_id

  associate_public_ip_address = true
  encrypt_boot                = true

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      architecture        = "x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }

    owners      = ["099720109477"]
    most_recent = true
  }

  ami_name        = "${var.ami_name_prefix}-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  ami_description = "OTMS Attendance API Ubuntu 22.04 AMI built by Packer"

  tags = {
    Name        = "${var.ami_name_prefix}-ami"
    Environment = var.environment
    Application = var.application
    Service     = "attendance"
    ManagedBy   = "Packer"
    Owner       = var.owner
    CostCenter  = var.cost_center
  }

  run_tags = {
    Name        = "${var.ami_name_prefix}-packer-builder"
    Environment = var.environment
    Application = var.application
    Service     = "attendance"
    ManagedBy   = "Packer"
    Owner       = var.owner
    CostCenter  = var.cost_center
  }
}

build {
  name = "attendance-api-ami"

  sources = [
    "source.amazon-ebs.attendance"
  ]

  provisioner "shell" {
    script = "${path.root}/scripts/install-attendance.sh"

    environment_vars = [
      "APP_REPO=${var.app_repo}",
      "APP_REF=${var.app_ref}",
      "POETRY_VERSION=${var.poetry_version}"
    ]

    execute_command = "chmod +x {{ .Path }}; sudo -E env {{ .Vars }} {{ .Path }}"
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}
