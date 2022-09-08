output "db_username" {
  description = "The master username for logging in to the database."
  value       = module.postgres_db.db_instance_username
  sensitive   = true
}

output "db_password" {
  description = "The password for logging in to the database."
  value       = module.postgres_db.db_instance_password
  sensitive   = true
}
