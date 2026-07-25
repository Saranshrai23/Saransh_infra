resource "aws_db_subnet_group" "attendance" {
  name        = "${var.environment}-${var.application}-attendance-db-subnet-group"
  description = "Database subnets for Attendance PostgreSQL"

  subnet_ids = [
    data.aws_subnet.database_a.id,
    data.aws_subnet.database_b.id
  ]

  tags = {
    Name = "${var.environment}-${var.application}-attendance-db-subnet-group"
  }
}

resource "aws_db_instance" "attendance" {
  identifier = var.postgres_identifier

  engine         = "postgres"
  instance_class = var.postgres_instance_class
  port           = 5432

  allocated_storage     = var.postgres_allocated_storage
  max_allocated_storage = var.postgres_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.postgres_database_name
  username = var.postgres_master_username

  # AWS RDS generates and stores the master password in Secrets Manager.
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.attendance.name
  vpc_security_group_ids = [aws_security_group.postgres.id]

  publicly_accessible = false
  multi_az            = var.postgres_multi_az

  backup_retention_period = var.postgres_backup_retention_days
  copy_tags_to_snapshot    = true

  auto_minor_version_upgrade = true
  apply_immediately          = true

  deletion_protection = var.postgres_deletion_protection
  skip_final_snapshot = var.postgres_skip_final_snapshot

  tags = {
    Name    = var.postgres_identifier
    Service = "attendance-postgres"
  }
}
