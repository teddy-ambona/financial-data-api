resource "aws_eip" "nat" {
  count = 1

  vpc = true
}

# Note that this module will also attach an internet gateway to the VPC.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name = "${local.environment}-my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  # Create one NAT gateway per subnet to keep number Elastic IP minimal and avoid incurring extra charges
  single_nat_gateway = true
  # Avoid provisioning a new Elastic IP
  reuse_nat_ips       = true
  external_nat_ip_ids = aws_eip.nat.*.id

  # enable_vpn_gateway  = true

  tags = {
    Terraform   = "true"
    Environment = local.environment
  }
}
