module "postgres_db" {
  source     = "terraform-aws-modules/rds/aws"
  version    = "5.0.3"
  identifier = "${var.environment}-demodb"

  engine            = "postgres"
  engine_version    = "14.2"
  instance_class    = "db.t2.micro"
  allocated_storage = 1

  db_name  = "market_data"
  username = "postgres"
  port     = "5432"

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [aws_security_group.db.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # DB option group
  major_engine_version = "5.7"

  # Database Deletion Protection
  deletion_protection = true

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }

}