output "target_group_arns" {
  description = "ARNs of the target groups."
  value       = module.ecs_alb.target_group_arns
}

output "http_tcp_listener_arns" {
  description = "The ARN of the TCP and HTTP load balancer listeners created."
  value       = module.ecs_alb.http_tcp_listener_arns
}
