aws_region  = "us-east-1"
environment = "dev"
application = "otms"

cost_center = "Snaatak"
owner       = "Infra-Titans"

vpc_name = "dev-otms-vpc"

public_subnet_a_name = "dev_otms_public_subnet_a"
public_subnet_b_name = "dev_otms_public_subnet_b"

certificate_arn = "arn:aws:acm:us-east-1:788572613316:certificate/e988e494-7ffa-4d38-8589-62f2329008b7"

ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"

frontend_port     = 3000
employee_port     = 8080
attendance_port   = 8081
salary_port       = 8082
notification_port = 8085

frontend_health_check     = "/"
employee_health_check     = "/"
attendance_health_check   = "/"
salary_health_check       = "/"
notification_health_check = "/"
