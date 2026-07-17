variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "application" {
  type = string
}

variable "owner" {
  type = string
}

variable "cost_center" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "notification_sg_name" {
  type = string
}

variable "notification_port" {
  type = number
}
