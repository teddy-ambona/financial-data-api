dependencies {
  # Relative paths to the directory where terragrunt is run
  paths = []
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
EOF
}
