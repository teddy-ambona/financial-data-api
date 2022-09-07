# Set common variables for the environment. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.

# Set as [local values](https://www.terraform.io/docs/configuration/locals.html)
locals {
  aws_region          = "us-east-1"
  aws_account_id      = "165453727631"
  remote_state_bucket = "financial-data-api-demo-state"
}
