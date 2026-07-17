aws_region = "us-east-1"

vpc_id = "vpc-xxxxxxxx"

target_group_name = "dev-otms-notification-tg"

target_group_port = 8085

target_group_protocol = "HTTP"

target_type = "instance"

health_check_path = "/api/v1/notification/health/detail"

health_check_matcher = "200"

application = "Notification"

owner = "Infra-Titans"

environment = "dev"

cost_center = "Snaatak"
