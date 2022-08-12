# Allows fetching information about the user who runs this script.
data "aws_caller_identity" "current" {}

# Create user
resource "aws_iam_user" "demo_user" {
  name = "demo_user"
}

# Create access key
resource "aws_iam_access_key" "demo_user" {
  user = aws_iam_user.demo_user.name
}

# Strenghten IAM password policy
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 8
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 90 # Password expires after 90 days
}

# Create policy document (minimum AWS permissions necessary for a Terraform run).
data "aws_iam_policy_document" "demo_policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::financial-data-api-demo"]
  }

  statement {
    effect    = "Allow"
    actions   = ["dynamodb:*"]
    resources = ["arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/financial-data-api-demo-locks"]
  }

  # statement {
  #   effect    = "Allow"
  #   actions   = ["iam:*"]
  #   resources = ["arn:aws:iam:::*"]
  # }

  statement {
    effect    = "Deny"
    actions   = [
      "iam:*User*",
      "iam:*Login*",
      "iam:*Group*",
      "iam:*Provider*",
      "aws-portal:*",
      "budgets:*",
      "config:*",
      "directconnect:*",
      "aws-marketplace:*",
      "aws-marketplace-management:*",
      "ec2:*ReservedInstances*"
    ]
    resources = ["*"]
  }
}

# Create policy from policy document
resource "aws_iam_policy" "policy_document" {
  name   = "demo-policy-document"
  policy = data.aws_iam_policy_document.demo_policy.json
}

# Assign policy to demo user
resource "aws_iam_user_policy_attachment" "attach-policy" {
  user       = aws_iam_user.demo_user.name
  policy_arn = aws_iam_policy.policy_document.arn
}
