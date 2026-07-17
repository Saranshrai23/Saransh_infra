output "notification_target_group_id" {

  description = "Notification Target Group ID"

  value = aws_lb_target_group.notification_tg.id

}

output "notification_target_group_arn" {

  description = "Notification Target Group ARN"

  value = aws_lb_target_group.notification_tg.arn

}

output "notification_target_group_name" {

  description = "Notification Target Group Name"

  value = aws_lb_target_group.notification_tg.name

}
