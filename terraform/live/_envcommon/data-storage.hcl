dependencies {
  paths = ["../vpc", "../security-groups"]
}

locals {
  # Automatically load environment-level variables
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

generate "common" {
  path      = "terragrunt_common.tf"
  if_exists = "overwrite"
  contents  = <<EOF
locals {
  # use short name if possible, because some resources have length limit on its name.
  name_prefix    = "${local.env_vars.locals.application}-${local.env_vars.locals.environment}"

  environment    = "${local.env_vars.locals.environment}"
}

variable "instance_class" {
  type        = string
  description = "DB instance class"
}

variable "allocated_storage" {
  type        = number
  description = "size of the DB"
}

variable "db_username" {
  type        = string
  description = "DB username"
}

# Allow fetching VPC id from the state file
data "terraform_remote_state" "sg" {
  backend = "s3"

  config = {
    bucket = "${local.env_vars.locals.remote_state_bucket}"
    region = "${local.env_vars.locals.aws_region}"
    key = "${local.env_vars.locals.environment}/security-groups/terraform.tfstate"
  }
}

# Allow fetching VPC id from the state file
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "${local.env_vars.locals.remote_state_bucket}"
    region = "${local.env_vars.locals.aws_region}"
    key = "${local.env_vars.locals.environment}/vpc/terraform.tfstate"
  }
}
EOF
}
