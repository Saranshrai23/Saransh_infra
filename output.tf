output "attendance_api_security_group_id" {
  description = "The ID of the Security Group attached to the Attendance API"
  value       = aws_security_group.attendance_api_sg.id
}

output "attendance_api_launch_template_id" {
  description = "The ID of the Attendance API Launch Template"
  value       = aws_launch_template.attendance_api.id
}

output "attendance_api_launch_template_latest_version" {
  description = "The latest version of the Attendance API Launch Template"
  value       = aws_launch_template.attendance_api.latest_version
}

output "attendance_tg_arn" {
  description = "The ARN of the Attendance target group fetched from the network state"
  value       = data.terraform_remote_state.network.outputs.target_group_arns["attendance"]
}

output "attendance_api_asg_name" {
  description = "The name of the Attendance API Auto Scaling Group"
  value       = aws_autoscaling_group.attendance_api.name
}

output "attendance_api_cpu_policy_arn" {
  description = "The ARN of the Attendance API CPU auto-scaling policy"
  value       = aws_autoscaling_policy.attendance_cpu_scaling.arn
}
