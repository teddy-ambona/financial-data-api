output "db_sg_id" {
  description = "The ID of the DB security group"
  value       = module.db_sg.security_group_id
}

output "web_server_sg_id" {
  description = "The ID of the web-server security group"
  value       = module.web_server_sg.security_group_id
}
