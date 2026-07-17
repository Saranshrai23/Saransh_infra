resource "aws_security_group" "notification_sg" {

  name        = var.notification_sg_name
  description = "Security Group for Notification Application"
  vpc_id      = var.vpc_id

  ingress {

    description = "Allow traffic from Application Load Balancer"

    from_port = var.notification_port
    to_port   = var.notification_port
    protocol  = "tcp"

    security_groups = [
      var.alb_security_group_id
    ]

  }

  egress {

    description = "Allow all outbound traffic"

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]

  }

  tags = {

    Name = var.notification_sg_name

    Application = var.application

    Owner = var.owner

    Environment = var.environment

    CostCenter = var.cost_center

  }

}
