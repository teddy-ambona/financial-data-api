module "web_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.11.0"

  name                = "${local.name_prefix}-web-server-sg"
  description         = "Security group for web-server"
  vpc_id              = data.terraform_remote_state.vpc.output.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-${var.server_port}-tcp"]

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }

}

module "db_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.11.0"

  name        = "${local.name_prefix}-db-sg"
  description = "Security group for database"
  vpc_id      = data.terraform_remote_state.vpc.output.vpc_id

  # Only allow requests coming from private subnet "10.0.1.0/24"
  ingress_cidr_blocks = ["10.0.1.0/24"]
  ingress_rules       = ["postgresql-tcp"]

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }

}
