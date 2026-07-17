output "listener_rule_arn" {
  description = "Notification Listener Rule ARN"
  value       = aws_lb_listener_rule.notification_listener_rule.arn
}
