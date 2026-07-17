output "notification_security_group_id" {
  description = "ID of the Notification Security Group"
  value       = aws_security_group.notification_sg.id
}

output "notification_security_group_name" {
  description = "Name of the Notification Security Group"
  value       = aws_security_group.notification_sg.name
}

output "notification_security_group_arn" {
  description = "ARN of the Notification Security Group"
  value       = aws_security_group.notification_sg.arn
}
