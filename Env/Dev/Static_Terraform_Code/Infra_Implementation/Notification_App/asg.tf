resource "aws_autoscaling_group" "notification_asg" {

  name = "${var.instance_name}-asg"

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.notification_lt.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300

  force_delete = true

  tag {
    key                 = "Name"
    value               = var.instance_name
    propagate_at_launch = true
  }
}
