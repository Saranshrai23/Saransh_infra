private_subnet_ids = [
  "subnet-xxxxxxxx",
  "subnet-yyyyyyyy"
]

target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/notification-tg/xxxxxxxx"

min_size         = 1
max_size         = 2
desired_capacity = 1
