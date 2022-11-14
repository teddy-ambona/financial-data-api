# Create a random DB password
resource "random_password" "db_password" {
  length  = 16
  special = true
  numeric = true
  upper   = true
  lower   = true
}

# Add DB credentials to AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "db/credentials"
  description = "Credentials for the RDS Postgres DB"
  tags = {
    Terraform   = "true"
    Environment = local.environment
  }
}

# Create a new secret version
resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = <<EOF
{
  "DB_USERNAME": "${var.db_username}",
  "DB_PASSWORD": "${random_password.db_password.result}"
}
EOF
}

module "postgres_db" {
  source     = "terraform-aws-modules/rds/aws"
  version    = "5.0.3"
  identifier = "${local.environment}-demodb"

  engine         = "postgres"
  engine_version = "14.3"

  # DB instance which supports encryption
  instance_class = var.instance_class

  # The allocated storage in gigabytes, AWS requires a minimum of 20Gb
  allocated_storage = var.allocated_storage

  db_name                = "market_data"
  username               = var.db_username
  create_random_password = false
  password               = random_password.db_password.result
  port                   = "5432"

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [data.terraform_remote_state.sg.outputs.db_sg_id]

  # Multi availability zones for Disaster Recovery with automatic failover to the standby instance
  # The standby instance cannot be queried and becomes useful only when failure happens with primary.
  # Should be "true" in production
  multi_az = false

  # Associate DB to private subnets in order to avoid connection from the internet.
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets_ids

  # Need to create a new subnet group cf https://github.com/terraform-aws-modules/terraform-aws-rds/issues/395
  create_db_subnet_group = true

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # DB parameter group
  family = "postgres14"

  # DB option group
  major_engine_version = "14.2"

  # Database Deletion Protection
  deletion_protection = true

  tags = {
    Terraform   = "true"
    Environment = local.environment
  }

}
