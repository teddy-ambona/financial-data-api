# Note that this module will also attach an internet gateway to the VPC.
#tfsec:ignore:aws-ec2-no-public-ip-subnet
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.14"

  name = "${local.environment}-my-vpc"
  cidr = "10.0.0.0/16"

  # Multi-AZ VPC, each availability zone has a private and a public subnet.
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  # The NAT Gateway enables resources in the private subnet to communicate
  # with the internet (for installing DB software for instance, but RDS doesn't need it).
  # This is an expensive feature
  # cf https://medium.com/@balint_sera/nat-gateway-is-expensive-and-you-probably-dont-need-it-to-run-24-hours-a-day-17c9a5150f45
  enable_nat_gateway = true
  single_nat_gateway = true

  # Set DNS parameters to "true" to enable Route 53 private hosted zone (dev.custom_db_hostname.com)
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = local.environment
  }
}
