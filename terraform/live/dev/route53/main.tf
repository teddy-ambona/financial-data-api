# Create private hosted zone (only accessible within VPC)
resource "aws_route53_zone" "dev" {
  name = "dev.custom_db_hostname.com"

  vpc {
    vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  }

  tags = {
    Terraform   = "true"
    Environment = local.environment
  }
}

# Create an alias record to map "dev.custom_db_hostname.com" to the RDS DB address
resource "aws_route53_record" "dev-ns" {
  zone_id = aws_route53_zone.dev.zone_id
  name    = "dev.custom_db_hostname.com"
  type    = "A"

  alias {
    name    = data.terraform_remote_state.postgres_db.outputs.db_instance_address
    zone_id = data.terraform_remote_state.postgres_db.outputs.db_instance_hosted_zone_id
    evaluate_target_health = true
  }
}
