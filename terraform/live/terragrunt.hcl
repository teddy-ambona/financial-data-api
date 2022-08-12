terraform_version_constraint = ">= 1.0.0"

remote_state {
  backend = "s3"
  generate = {
    path      = "terragrunt_backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "${local.common.locals.remote_state_bucket}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "${local.common.locals.aws_region}"
    dynamodb_table = "financial-data-api-demo-locks"
    encrypt        = true
  }
}

terraform {
  # Force Terraform to keep trying to acquire a lock for
  # up to 20 minutes if someone else already has the lock
  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=20m"]
  }
}

generate "provider" {
  path = "terragrunt_provider.tf"
  if_exists = "overwrite"
  contents = <<EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "${local.common.locals.aws_region}"

  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${local.common.locals.aws_account_id}"]
}
EOF
}

# ----------------------------------------------------------------
# Configure root level variables that all resources can inherit.
# ----------------------------------------------------------------

// locals {
//   # Load the data from common.hcl
//   common = read_terragrunt_config(find_in_parent_folders("common.hcl"))
// }

// generate "common" {
//   path = "terragrunt_common.tf"
//   if_exists = "overwrite"
//   contents = <<EOF
// variable "remote_state_bucket" {
//   type = string
//   default = "${local.common.locals.remote_state_bucket}"
// }
// EOF
// }
