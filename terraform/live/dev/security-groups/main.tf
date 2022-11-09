#tfsec:ignore:aws-ec2-no-public-egress-sgr
module "web_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~>4.16"

  name        = "${local.name_prefix}-web-server-sg"
  description = "Security group for web-server"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # Allow webserver to only allow incomming traffic from instances that have the
  # "alb_sg" security-group attached to them
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  # Add egress rule so that the ECS service can do "docker pull" and also connect to the RDS instance.
  # Docker Hub does not have a list of static IP addressed so we allow all IPs. Migrating to ECR could provide
  # better security standards.
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["http-8080-tcp", "https-443-tcp", "postgresql-tcp"]

  tags = {
    Terraform   = "true"
    Environment = local.environment
  }

}

module "db_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~>4.16"

  name        = "${local.name_prefix}-db-sg"
  description = "Security group for database"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # Only allow requests coming from VPC CIDR blocks
  ingress_cidr_blocks = concat(
    data.terraform_remote_state.vpc.outputs.private_subnets_cidr_blocks,
    data.terraform_remote_state.vpc.outputs.public_subnets_cidr_blocks
  )
  ingress_rules = ["postgresql-tcp"]

  tags = {
    Terraform   = "true"
    Environment = local.environment
  }

}

# Bug from tfsec where it thinks this sg is allowing all incoming traffic from the internet
#tfsec:ignore:aws-ec2-no-public-ingress-sgr
#tfsec:ignore:aws-ec2-no-public-egress-sgr
module "bastion_host_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~>4.16"

  name        = "${local.name_prefix}-bastion-host-sg"
  description = "Security group for the bastion host"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  # Only whitelist EC2 instance connect for incoming requests
  # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-set-up.html
  # cf [https://ip-ranges.amazonaws.com/ip-ranges.json] --> us-east-1: 18.206.107.24/29
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "EC2 Instance connect"
      cidr_blocks = "18.206.107.24/29"
    }
  ]
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["http-8080-tcp", "https-443-tcp", "postgresql-tcp"]

  tags = {
    Terraform   = "true"
    Environment = local.environment
  }

}

# Application Load Balancer security group
#tfsec:ignore:aws-ec2-no-public-ingress-sgr
module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~>4.16"

  name                = "${local.name_prefix}-alb-sg"
  description         = "Security group for ALB"
  vpc_id              = data.terraform_remote_state.vpc.outputs.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]

  # Allow ALB to only send outbound request to instances that have the
  # "web_server_sg" security-group attached to them
  computed_egress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.web_server_sg.security_group_id
    }
  ]
  number_of_computed_egress_with_source_security_group_id = 1

  tags = {
    Terraform   = "true"
    Environment = local.environment
  }
}
