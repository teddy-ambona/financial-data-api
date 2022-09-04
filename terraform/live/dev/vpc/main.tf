resource "aws_eip" "nat" {
  count = 1

  vpc = true
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name = "${var.environment}-my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  enable_nat_gateway = true
  # Create one NAT gateway per subnet to keep number Elastic IP minimal and avoid incurring extra charges
  single_nat_gateway = true
  # Avoid provisioning a new Elastic IP
  reuse_nat_ips       = true
  external_nat_ip_ids = aws_eip.nat

  # enable_vpn_gateway  = true

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

# Allow communication between your VPC and the internet.
resource "aws_internet_gateway" "gw" {
  vpc_id = module.vpc.output.vpc_id

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}
