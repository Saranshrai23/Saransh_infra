resource "aws_security_group" "notification_sg" {

  name        = var.notification_sg_name
  description = "Security Group for Notification Application"
  vpc_id      = var.vpc_id

  ingress {

    description = "Application Port"

    from_port = var.notification_port

    to_port = var.notification_port

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]

  }

  egress {

    description = "Allow All Outbound"

    from_port = 0

    to_port = 0

    protocol = "-1"

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
