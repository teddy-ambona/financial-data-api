# TFLint ruleset plugin for Terraform AWS Provider
# Check rules here: https://github.com/terraform-linters/tflint-ruleset-aws/blob/master/docs/rules/README.md
plugin "aws" {
  enabled = true
  version = "0.16.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
