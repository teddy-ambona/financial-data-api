output "aws_region" {
  value = data.aws_region.current.name
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
  sensitive = true
}

output "aws_account_alias" {
  value = data.aws_iam_account_alias.current.account_alias
  sensitive = true
}
