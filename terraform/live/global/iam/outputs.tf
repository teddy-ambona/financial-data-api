output "ecs_service_role_arn" {
  description = "Role to be assumed by ECS task"
  value       = aws_iam_role.ecs_task_execution_role.arn
}
