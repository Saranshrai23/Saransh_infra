variable "listener_arn" {
  description = "ALB Listener ARN"
  type        = string
}

variable "listener_priority" {
  description = "Listener Rule Priority"
  type        = number
}

variable "target_group_arn" {
  description = "Notification Target Group ARN"
  type        = string
}
