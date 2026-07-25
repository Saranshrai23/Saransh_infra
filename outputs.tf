output "vpc_id" {
  description = "Existing OTMS VPC ID."
  value       = data.aws_vpc.otms.id
}

output "database_subnet_ids" {
  description = "Database subnet IDs used by RDS and Redis."
  value = [
    data.aws_subnet.database_a.id,
    data.aws_subnet.database_b.id
  ]
}

output "attendance_app_security_group_id" {
  description = "Attach this SG to Attendance EC2 instances in the Launch Template."
  value       = aws_security_group.attendance_app.id
}

output "postgres_security_group_id" {
  value = aws_security_group.postgres.id
}

output "postgres_endpoint" {
  description = "Private RDS PostgreSQL hostname."
  value       = aws_db_instance.attendance.address
}

output "postgres_port" {
  value = aws_db_instance.attendance.port
}

output "postgres_database_name" {
  value = aws_db_instance.attendance.db_name
}

output "postgres_username" {
  value = aws_db_instance.attendance.username
}

output "postgres_master_secret_arn" {
  description = "Secrets Manager ARN containing the RDS master credentials."
  value       = aws_db_instance.attendance.master_user_secret[0].secret_arn
}

output "redis_security_group_id" {
  value = aws_security_group.redis.id
}

output "redis_endpoint" {
  description = "Private Redis primary endpoint."
  value       = aws_elasticache_replication_group.attendance.primary_endpoint_address
}

output "redis_port" {
  value = aws_elasticache_replication_group.attendance.port
}
