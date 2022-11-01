# Create a policy that allows accessing AWS Secrets Manager and connecting to RDS
#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "app_policy" {
  name        = "app_policy"
  path        = "/"
  description = "Policy that is used by the app"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "rds-db:connect",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# Create IAM Role for ECS Execution
# The execution role is the IAM role that executes ECS actions such as pulling the image and storing the application logs in cloudwatch.
module "ecs_task_execution_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~>5.5"

  # Allow ECS to assume role
  trusted_role_services = [
    "ecs-tasks.amazonaws.com"
  ]

  create_role       = true
  role_name         = "ecs_task_execution_role"
  role_requires_mfa = false

  # Attach above policy to role
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
  number_of_custom_role_policy_arns = 1
}


# Create IAM role for the ECS task itself and EC2 bastion host (useful for troubleshooting issues).
# This role should give access to AWS Secrets Manager and RDS.
module "app_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~>5.5"

  # Allow ECS tasks and EC2 bastion host to assume role
  trusted_role_services = [
    "ecs-tasks.amazonaws.com",
    "ec2.amazonaws.com"
  ]

  create_role       = true
  role_name         = "app_role"
  role_requires_mfa = false

  # Attach above policy to role
  custom_role_policy_arns = [
    aws_iam_policy.app_policy.arn
  ]
  number_of_custom_role_policy_arns = 1
}
