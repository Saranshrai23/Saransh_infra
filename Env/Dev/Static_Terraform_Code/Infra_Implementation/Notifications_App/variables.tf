variable "aws_region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "target_group_name" {
  type = string
}

variable "target_group_port" {
  type = number
}

variable "target_group_protocol" {
  type = string
}

variable "target_type" {
  type = string
}

variable "health_check_path" {
  type = string
}

variable "health_check_matcher" {
  type = string
}

variable "application" {
  type = string
}

variable "owner" {
  type = string
}

variable "environment" {
  type = string
}

variable "cost_center" {
  type = string
}
