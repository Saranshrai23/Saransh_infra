resource "aws_autoscaling_policy" "attendance_cpu_scaling" {
  name                   = "dev-otms-attendance-api-cpu-scaling"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.attendance_api.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70.0
  }
}
