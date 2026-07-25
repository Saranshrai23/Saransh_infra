# Attach this security group to Attendance EC2 instances
# through the Attendance Launch Template.
resource "aws_security_group" "attendance_app" {
  name        = "${var.environment}-${var.application}-attendance-app-sg"
  description = "Security group for Attendance API EC2 instances"
  vpc_id      = data.aws_vpc.otms.id

  tags = {
    Name = "${var.environment}-${var.application}-attendance-app-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "attendance_app_all_outbound" {
  security_group_id = aws_security_group.attendance_app.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "attendance-app-all-outbound"
  }
}

resource "aws_security_group" "postgres" {
  name        = "${var.environment}-${var.application}-attendance-postgres-sg"
  description = "Allow PostgreSQL only from Attendance API instances"
  vpc_id      = data.aws_vpc.otms.id

  tags = {
    Name = "${var.environment}-${var.application}-attendance-postgres-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "postgres_from_attendance" {
  security_group_id            = aws_security_group.postgres.id
  referenced_security_group_id = aws_security_group.attendance_app.id
  description                  = "PostgreSQL from Attendance application security group"
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432

  tags = {
    Name = "postgres-from-attendance"
  }
}

resource "aws_vpc_security_group_egress_rule" "postgres_all_outbound" {
  security_group_id = aws_security_group.postgres.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "postgres-all-outbound"
  }
}

resource "aws_security_group" "redis" {
  name        = "${var.environment}-${var.application}-attendance-redis-sg"
  description = "Allow Redis only from Attendance API instances"
  vpc_id      = data.aws_vpc.otms.id

  tags = {
    Name = "${var.environment}-${var.application}-attendance-redis-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "redis_from_attendance" {
  security_group_id            = aws_security_group.redis.id
  referenced_security_group_id = aws_security_group.attendance_app.id
  description                  = "Redis from Attendance application security group"
  ip_protocol                  = "tcp"
  from_port                    = 6379
  to_port                      = 6379

  tags = {
    Name = "redis-from-attendance"
  }
}

resource "aws_vpc_security_group_egress_rule" "redis_all_outbound" {
  security_group_id = aws_security_group.redis.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "redis-all-outbound"
  }
}
