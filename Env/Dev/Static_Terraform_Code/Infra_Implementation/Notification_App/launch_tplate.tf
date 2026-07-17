resource "aws_launch_template" "notification_lt" {

  name_prefix = "${var.instance_name}-"

  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = var.security_group_ids

  block_device_mappings {

    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  monitoring {
    enabled = false
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = var.instance_name
    }
  }

  tags = {
    Name = "${var.instance_name}-lt"
  }
}
