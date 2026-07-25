resource "aws_elasticache_subnet_group" "attendance" {
  name        = "${var.environment}-${var.application}-attendance-redis-subnet-group"
  description = "Database subnets used by Attendance Redis"

  subnet_ids = [
    data.aws_subnet.database_a.id,
    data.aws_subnet.database_b.id
  ]

  tags = {
    Name = "${var.environment}-${var.application}-attendance-redis-subnet-group"
  }
}

# Development setup: one Redis primary and no replica.
# It remains private and can only be reached from the Attendance app SG.
resource "aws_elasticache_replication_group" "attendance" {
  replication_group_id = var.redis_replication_group_id
  description          = "Redis cache for OTMS Attendance API"

  engine         = "redis"
  engine_version = var.redis_engine_version
  node_type      = var.redis_node_type
  port           = 6379

  num_cache_clusters         = 1
  automatic_failover_enabled = false
  multi_az_enabled           = false

  parameter_group_name = var.redis_parameter_group_name
  subnet_group_name    = aws_elasticache_subnet_group.attendance.name
  security_group_ids   = [aws_security_group.redis.id]

  at_rest_encryption_enabled = true

  # Kept false because the current Attendance configuration does not
  # contain a Redis TLS option. Enable only after the app supports TLS.
  transit_encryption_enabled = false

  snapshot_retention_limit = var.redis_snapshot_retention_days
  apply_immediately        = true

  tags = {
    Name    = var.redis_replication_group_id
    Service = "attendance-redis"
  }
}
