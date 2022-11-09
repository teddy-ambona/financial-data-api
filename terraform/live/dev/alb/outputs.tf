output "target_group_arns" {
  description = "ARNs of the target groups."
  value       = module.ecs_alb.target_group_arns
}
