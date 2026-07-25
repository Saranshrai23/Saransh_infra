# Attendance Data Layer — PostgreSQL + Redis

Ye Terraform code existing network skeleton ko use karta hai.

Existing resources looked up by Name tag:

```text
VPC:
dev-otms-vpc

Database subnets:
dev_otms_database_subnet_a
dev_otms_database_subnet_b
```

## Ye code kya create karega?

```text
Attendance Application Security Group
        |
        | TCP 5432
        v
RDS PostgreSQL Security Group
        |
        v
RDS PostgreSQL in database subnet group

Attendance Application Security Group
        |
        | TCP 6379
        v
Redis Security Group
        |
        v
ElastiCache Redis in database subnet group
```

PostgreSQL aur Redis public nahi honge. Sirf woh EC2 instances connect kar sakenge jinpar output wala Attendance application SG attach hoga.

## Folder structure

```text
attendance-data-layer-terraform/
├── versions.tf
├── provider.tf
├── variables.tf
├── data.tf
├── security-groups.tf
├── rds.tf
├── redis.tf
├── outputs.tf
└── terraform.tfvars.example
```

## Run

```bash
cp terraform.tfvars.example terraform.tfvars

terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

## Apply ke baad outputs

```bash
terraform output
```

Important outputs:

```text
attendance_app_security_group_id
postgres_endpoint
postgres_port
postgres_database_name
postgres_username
postgres_master_secret_arn
redis_endpoint
redis_port
```

## RDS password kaise milega?

Password Terraform file mein hardcode nahi hai. AWS RDS password generate karke Secrets Manager mein rakhega.

Secret ARN:

```bash
terraform output -raw postgres_master_secret_arn
```

Secret value check:

```bash
aws secretsmanager get-secret-value \
  --secret-id "$(terraform output -raw postgres_master_secret_arn)" \
  --query SecretString \
  --output text
```

Expected JSON mein username aur password milenge.

## Launch Template mein kya use karna hai?

Attendance Launch Template ke EC2 security groups mein ye attach karo:

```bash
terraform output -raw attendance_app_security_group_id
```

Runtime values:

```bash
POSTGRES_HOST=$(terraform output -raw postgres_endpoint)
POSTGRES_PORT=$(terraform output -raw postgres_port)
POSTGRES_DB=$(terraform output -raw postgres_database_name)

REDIS_HOST=$(terraform output -raw redis_endpoint)
REDIS_PORT=$(terraform output -raw redis_port)
REDIS_PASSWORD=
```

RDS username/password Secrets Manager se fetch karne hain.

## Important

Redis ke liye abhi:

```text
At-rest encryption: enabled
Transit encryption/TLS: disabled
Redis password: empty
```

Reason: current Attendance config mein Redis TLS flag nahi hai. Network access phir bhi private SG-to-SG rule se restricted hai.

Production mein Redis replica, Multi-AZ, TLS aur authentication enable karna better hoga.
