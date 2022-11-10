output "db_sg_id" {
  description = "The ID of the DB security group"
  value       = module.db_sg.security_group_id
}

output "web_server_sg_id" {
  description = "The ID of the web-server security group"
  value       = module.web_server_sg.security_group_id
}

output "bastion_host_sg_id" {
  description = "The ID of the bastion host security group"
  value       = module.bastion_host_sg.security_group_id
}

output "alb_sg_id" {
  description = "The ID of the ALB security group"
  value       = module.alb_sg.security_group_id
}

output "api_gw_sg_id" {
  description = "The ID of the API Gateway security group"
  value       = module.api_gw_sg.security_group_id
}