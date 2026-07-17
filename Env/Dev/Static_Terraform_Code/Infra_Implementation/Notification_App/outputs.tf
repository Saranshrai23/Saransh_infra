output "autoscaling_group_name" {
  value = aws_autoscaling_group.notification_asg.name
}

output "autoscaling_group_arn" {
  value = aws_autoscaling_group.notification_asg.arn
}
