variable "aws_region" {
  type = string
}

variable "autoscaling_group_name" {
  type = string
}

variable "scale_policy_name" {
  type = string
}

variable "target_cpu_utilization" {
  type = number
}
