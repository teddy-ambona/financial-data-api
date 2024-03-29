# Set common variables for the environment. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.

# Set as [local values](https://www.terraform.io/docs/configuration/locals.html)
locals {
  aws_region          = "us-east-1"
  aws_account_id      = "<YOUR_AWS_ACCOUNT_ID>"
  environment         = "dev"
  remote_state_bucket = "dev-financial-data-api-demo-state"
  application         = "api-demo"
}
