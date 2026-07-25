# Attendance API AMI with Packer

This Packer template creates an encrypted, EBS-backed Ubuntu 22.04 AMI for the OTMS Attendance API.

The image contains:

- Python 3.11
- Poetry and the Attendance API source code
- Gunicorn listening on port `8081`
- PostgreSQL with the `attendance_db` database
- Redis
- Liquibase and the PostgreSQL JDBC driver
- A systemd service named `attendance-api.service`
- A build-time health check for both the API and its PostgreSQL/Redis dependencies

## Directory structure

```text
attendance-packer/
├── attendance.pkr.hcl
├── dev.pkrvars.hcl.example
├── README.md
└── scripts/
    └── install-attendance.sh
```

## 1. Prepare the variables file

```bash
cp dev.pkrvars.hcl.example dev.pkrvars.hcl
nano dev.pkrvars.hcl
```

Set the VPC ID and a **public subnet ID**. The temporary Packer instance needs outbound internet access to install packages and clone the application repository.

## 2. Confirm AWS credentials

Packer automatically uses the normal AWS credential chain. For example:

```bash
aws sts get-caller-identity
```

Do not put AWS access keys inside the Packer template.

## 3. Build the AMI

```bash
packer init .
packer fmt .
packer validate -var-file=dev.pkrvars.hcl .
packer build -var-file=dev.pkrvars.hcl .
```

The generated AMI ID is printed by Packer and is also recorded in `manifest.json`.

## 4. Verify an EC2 instance launched from the AMI

The EC2 security group should allow port `8081` only from the Attendance target group's ALB security group.

```bash
sudo systemctl status attendance-api
curl http://127.0.0.1:8081/api/v1/attendance/health
curl http://127.0.0.1:8081/api/v1/attendance/health/detail
journalctl -u attendance-api -f
```

## Important design note

This version intentionally follows the supplied development setup and installs PostgreSQL and Redis on the same AMI. That is suitable for a demo or development environment. For production, keep the AMI stateless: use RDS PostgreSQL and ElastiCache Redis, obtain passwords from AWS Secrets Manager or Parameter Store at boot, and run database migrations as a separate deployment step.
