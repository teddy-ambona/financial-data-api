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

output "db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)."
  value       = module.postgres_db.db_instance_hosted_zone_id
}

output "db_instance_address" {
  description = "The address of the RDS instance (to be used in a Route 53 Alias record)."
  value       = module.postgres_db.db_instance_address
}
