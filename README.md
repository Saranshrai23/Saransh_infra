# Attendance API AMI with Packer

This Packer template creates an encrypted Ubuntu 22.04 AMI for the OTMS Attendance API.

The AMI contains:

- Python 3.11
- Poetry and the Attendance API source code
- Gunicorn on port `8081`
- PostgreSQL client libraries only
- Local Redis
- `attendance-api.service`
- Runtime support for an external PostgreSQL database in a secured DB subnet

PostgreSQL server, database passwords, and database migrations are **not** baked into the AMI.

## Directory structure

```text
attendance-packer/
├── attendance.pkr.hcl
├── dev.pkrvars.hcl.example
├── launch-template-user-data.sh.example
├── README.md
└── scripts/
    └── install-attendance.sh
```

## 1. Build the AMI

```bash
cp dev.pkrvars.hcl.example dev.pkrvars.hcl
nano dev.pkrvars.hcl

packer init .
packer fmt .
packer validate -var-file=dev.pkrvars.hcl .
packer build -var-file=dev.pkrvars.hcl .
```

The temporary Packer instance uses the public subnet configured in `dev.pkrvars.hcl` so it can download packages and clone the Git repository.

## 2. Supply database configuration when EC2 starts

The AMI does not start the Attendance API during image creation. The Launch Template user-data must create:

```text
/etc/attendance-api/attendance.env
```

Use `launch-template-user-data.sh.example` as the starting point. The required values are:

```text
DB_HOST=<private PostgreSQL/RDS endpoint>
DB_PORT=5432
DB_NAME=attendance_db
DB_USER=<database user>
DB_PASSWORD=<secret value>
```

After creating the environment file, user-data runs:

```bash
systemctl enable --now attendance-api
```

For real deployments, retrieve `DB_PASSWORD` from AWS Secrets Manager or Systems Manager Parameter Store instead of hardcoding it in Terraform or Git.

## 3. Required security-group connectivity

The PostgreSQL security group should allow:

```text
Protocol: TCP
Port: 5432
Source: Attendance application security group
```

The database does not need public access. Application and database instances can communicate across different private subnets through the VPC local route, subject to security groups and network ACLs.

The Attendance application security group should allow port `8081` only from the ALB security group.

## 4. Database migrations

Do not run Liquibase during the Packer build. Run migrations as a separate Jenkins/deployment stage from a runner that can reach the private database endpoint.

## 5. Verification after EC2 launch

```bash
sudo systemctl status attendance-api
sudo journalctl -u attendance-api -n 100 --no-pager
curl http://127.0.0.1:8081/api/v1/attendance/health
curl http://127.0.0.1:8081/api/v1/attendance/health/detail
```
