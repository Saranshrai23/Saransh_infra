output "launch_template_id" {
  value = aws_launch_template.notification_lt.id
}

output "launch_template_latest_version" {
  value = aws_launch_template.notification_lt.latest_version
}
