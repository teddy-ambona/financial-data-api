terraform_version_constraint = ">= 1.0.0"

generate "provider" {
  path      = "terragrunt_provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "${local.env_vars.aws_region}"
}
EOF
}

locals {
  # Automatically load environment-level variables
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}
