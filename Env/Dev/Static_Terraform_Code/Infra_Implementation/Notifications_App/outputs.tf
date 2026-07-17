output "autoscaling_policy_arn" {

  description = "Notification Auto Scaling Policy ARN"

  value = aws_autoscaling_policy.notification_target_tracking.arn

}

output "autoscaling_policy_name" {

  description = "Notification Auto Scaling Policy Name"

  value = aws_autoscaling_policy.notification_target_tracking.name

}
