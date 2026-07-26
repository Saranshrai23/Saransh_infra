resource "aws_security_group" "attendance_api_sg" {
  name        = "dev-otms-attendance-api-sg"
  description = "Security Group for the Attendance API backend service"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description = "Allow Attendance API traffic from the ALB on port 8081"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"

    security_groups = [
      data.terraform_remote_state.network.outputs.alb_security_group_id
    ]
  }

  egress {
    description = "Allow outbound traffic to RDS, Redis and required internet services"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name    = "dev-otms-attendance-api-sg"
      Service = "attendance"
    }
  )
}
