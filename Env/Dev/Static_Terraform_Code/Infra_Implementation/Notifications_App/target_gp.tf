resource "aws_lb_target_group" "notification_tg" {

  name        = var.target_group_name
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  deregistration_delay = 30

  health_check {

    enabled             = true
    protocol            = var.target_group_protocol
    path                = var.health_check_path
    matcher             = var.health_check_matcher

    interval            = 30
    timeout             = 5

    healthy_threshold   = 3
    unhealthy_threshold = 2

  }

  tags = {

    Name        = var.target_group_name
    Application = var.application
    Owner       = var.owner
    Environment = var.environment
    CostCenter  = var.cost_center

  }

}
