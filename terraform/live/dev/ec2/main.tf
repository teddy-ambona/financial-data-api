# Generate a set of public and private keys
resource "tls_private_key" "bastion_host" {
  algorithm = "RSA"
}

# Provide an EC2 key pair resource
resource "aws_key_pair" "bastion_host" {
  key_name   = "bastion_host_key"
  public_key = tls_private_key.bastion_host.public_key_openssh
}

# Create EC2 instance profile.
# IAM instance profile is the entity that allows IAM role attachment with an EC2 instance.
# Conceptually, an instance profile acts like a vessel that contains only one IAM role that an EC2 instance can assume.
resource "aws_iam_instance_profile" "bastion_host_profile" {
  name = "bastion_host_profile"
  role = "app_role"
}

# Create bastion host EC2 instance
resource "aws_instance" "bastion_host" {
  # amzn2-ami-kernel-5.10-hvm-2.0.20221004.0-x86_64-gp2
  ami                         = var.ami
  instance_type               = var.instance_class
  key_name                    = aws_key_pair.bastion_host.key_name
  subnet_id                   = data.terraform_remote_state.vpc.outputs.public_subnets_ids[0]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.bastion_host_profile.name

  # Encrypt default EBS device
  root_block_device {
    encrypted = true
  }

  # Activate session tokens for Instance Metadata Service
  # cf https://aquasecurity.github.io/tfsec/v1.28.0/checks/aws/ec2/enforce-http-token-imds/
  metadata_options {
    http_tokens = "required"
  }

  # Security group that limits inbound traffic to SSH instance connect only
  security_groups = [data.terraform_remote_state.sg.outputs.bastion_host_sg_id]

  # Script that will be run at launch time
  user_data = file("bastion_host_user_data.sh")

  tags = {
    Name        = "bastion-host"
    Terraform   = "true"
    Environment = local.environment
  }
}
