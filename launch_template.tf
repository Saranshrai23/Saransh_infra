resource "aws_launch_template" "attendance_api" {
  name_prefix = "dev-otms-attendance-api-lt-"
  description = "Launch template for the Attendance API backend"

  image_id      = var.ami_id
  instance_type = "t3.small"

  iam_instance_profile {
    name = "dev-otms-ssm-role"
  }

  key_name = data.terraform_remote_state.network.outputs.key_pair_name

  network_interfaces {
    device_index                = 0
    associate_public_ip_address = false
    security_groups             = [aws_security_group.attendance_api_sg.id]
  }

  # Increase the root EBS volume size.
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = 30
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.common_tags,
      {
        Name    = "dev-otms-attendance-api-asg-instance"
        Service = "attendance"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.common_tags,
      {
        Name    = "dev-otms-attendance-api-volume"
        Service = "attendance"
      }
    )
  }

  tags = merge(
    var.common_tags,
    {
      Name    = "dev-otms-attendance-api-lt"
      Service = "attendance"
    }
  )
}
