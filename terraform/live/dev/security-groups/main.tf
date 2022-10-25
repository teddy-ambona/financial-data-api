#tfsec:ignore:aws-ec2-no-public-ingress-sgr
module "web_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.11.0"

  name                = "${local.name_prefix}-web-server-sg"
  description         = "Security group for web-server"
  vpc_id              = data.terraform_remote_state.vpc.outputs.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-8080-tcp"]

  # Add egress rule so that the ECS service can do "docker pull"
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["http-8080-tcp", "https-443-tcp"]

  tags = {
    Terraform   = "true"
    Environment = local.environment
  }

}

module "db_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.11.0"

  name        = "${local.name_prefix}-db-sg"
  description = "Security group for database"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # Only allow requests coming from VPC CIDR blocks
  ingress_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.101.0/24", "10.0.102.0/24"]
  ingress_rules       = ["postgresql-tcp"]

  tags = {
    Terraform   = "true"
    Environment = local.environment
  }

}
