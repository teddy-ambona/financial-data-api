terraform_version_constraint = ">= 1.0.0"

# Run `terragrunt output` on the module at the relative path `../data` and expose them under the attribute
# `dependency.data.outputs`
dependency "data" {
  config_path = "../data"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    aws_region = "us-east-1"
    aws_account_id = "123456789"
    aws_account_alias = "123456789"
  }
}

locals {
  # Automatically load environment-level variables
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

remote_state {
  backend = "s3"
  generate = {
    path      = "terragrunt_backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "${local.env_vars.locals.remote_state_bucket}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "${dependency.data.outputs.aws_region}"
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
  region = "${dependency.data.outputs.aws_region}"

  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${dependency.data.outputs.aws_account_id}"]
}
EOF
}
