resource "aws_lb_listener_rule" "notification_listener_rule" {

  listener_arn = var.listener_arn
  priority     = var.listener_priority

  action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }

  condition {
    path_pattern {
      values = [
        "/notification/*"
      ]
    }
  }

  tags = {
    Name = "${var.instance_name}-listener-rule"
  }
}
