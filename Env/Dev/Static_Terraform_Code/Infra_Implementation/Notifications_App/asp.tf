resource "aws_autoscaling_policy" "notification_target_tracking" {

  name                   = var.scale_policy_name
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = var.autoscaling_group_name

  target_tracking_configuration {

    predefined_metric_specification {

      predefined_metric_type = "ASGAverageCPUUtilization"

    }

    target_value = var.target_cpu_utilization

  }

}
