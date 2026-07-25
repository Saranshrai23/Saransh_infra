variable "aws_region" {
  description = "AWS region containing the existing OTMS VPC."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "application" {
  description = "Application name used in tags."
  type        = string
  default     = "otms"
}

variable "owner" {
  description = "Resource owner used in tags."
  type        = string
  default     = "Infra-Titans"
}

variable "cost_center" {
  description = "Cost center used in tags."
  type        = string
  default     = "Snaatak"
}

variable "vpc_name" {
  description = "Name tag of the existing VPC."
  type        = string
  default     = "dev-otms-vpc"
}

variable "database_subnet_a_name" {
  description = "Name tag of database subnet A."
  type        = string
  default     = "dev_otms_database_subnet_a"
}

variable "database_subnet_b_name" {
  description = "Name tag of database subnet B."
  type        = string
  default     = "dev_otms_database_subnet_b"
}

variable "postgres_identifier" {
  description = "RDS DB instance identifier."
  type        = string
  default     = "dev-otms-attendance-postgres"
}

variable "postgres_database_name" {
  description = "Initial PostgreSQL database used by Attendance API."
  type        = string
  default     = "attendance_db"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]{0,62}$", var.postgres_database_name))
    error_message = "PostgreSQL database name must start with a letter and contain only letters, numbers, or underscores."
  }
}

variable "postgres_master_username" {
  description = "RDS master username. RDS creates the password in Secrets Manager."
  type        = string
  default     = "attendance_admin"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]{0,15}$", var.postgres_master_username))
    error_message = "PostgreSQL master username must start with a letter and be at most 16 letters, numbers, or underscores."
  }
}

variable "postgres_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "postgres_allocated_storage" {
  description = "Initial RDS storage in GiB."
  type        = number
  default     = 20
}

variable "postgres_max_allocated_storage" {
  description = "Maximum RDS storage autoscaling limit in GiB."
  type        = number
  default     = 100
}

variable "postgres_multi_az" {
  description = "Enable RDS Multi-AZ."
  type        = bool
  default     = false
}

variable "postgres_backup_retention_days" {
  description = "Number of days to retain RDS automated backups."
  type        = number
  default     = 1
}

variable "postgres_skip_final_snapshot" {
  description = "Skip final snapshot when deleting RDS. Keep true only for dev."
  type        = bool
  default     = true
}

variable "postgres_deletion_protection" {
  description = "Enable RDS deletion protection."
  type        = bool
  default     = false
}

variable "redis_replication_group_id" {
  description = "ElastiCache Redis replication group identifier."
  type        = string
  default     = "dev-otms-attendance-redis"
}

variable "redis_node_type" {
  description = "ElastiCache Redis node type."
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_engine_version" {
  description = "Redis major and minor engine version."
  type        = string
  default     = "7.1"
}

variable "redis_parameter_group_name" {
  description = "Redis parameter group matching the engine version."
  type        = string
  default     = "default.redis7"
}

variable "redis_snapshot_retention_days" {
  description = "Redis snapshot retention period in days."
  type        = number
  default     = 1
}
