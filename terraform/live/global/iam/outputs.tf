output "ecs_task_execution_role_arn" {
  description = "Role that executes ECS actions such as pulling the image and storing the application logs in cloudwatch"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_role_arn" {
  description = "Role to be assumed by the ECS task itself"
  value       = aws_iam_role.ecs_task_role.arn
}
