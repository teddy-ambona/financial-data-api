output "ecs_task_execution_role_arn" {
  description = "Role that executes ECS actions such as pulling the image and storing the application logs in cloudwatch"
  value       = module.ecs_task_execution_role.iam_role_arn
}

output "app_role_arn" {
  description = "Role to be assumed by the ECS task itself and the EC2 bastion host"
  value       = module.app_role.iam_role_arn
}
