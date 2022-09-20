module "postgres_db" {
  source     = "terraform-aws-modules/rds/aws"
  version    = "5.0.3"
  identifier = "${local.environment}-demodb"

  engine         = "postgres"
  engine_version = "14.2"

  # DB instance which supports encryption
  instance_class = "db.t3.micro"

  # The allocated storage in gigabytes, AWS requires a minimum of 20Gb
  allocated_storage = 20

  db_name  = "market_data"
  username = "postgres"
  port     = "5432"

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [data.terraform_remote_state.sg.outputs.db_sg_id]

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
