# Create IAM policy document with trusted entities
data "aws_iam_policy_document" "ecs_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Create IAM Role for ECS Execution
# The execution role is the IAM role that executes ECS actions such as pulling the image and storing the application logs in cloudwatch.
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs-financial-data-api-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# The task role is the IAM role used by the task itself. For example, if your container wants to call
# other AWS services like S3, SQS, etc then those permissions would need to be covered by the task role.
resource "aws_iam_role" "ecs_task_role" {
  name               = "ecs-financial-data-api-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_role.json
}

# Create a policy that allows accessing AWS Secrets Manager
#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "ecs_task_policy" {
  name        = "ecs_task_policy"
  path        = "/"
  description = "Policy to be applied to the ECS task"

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

# Attach above policy to the task role
resource "aws_iam_role_policy_attachment" "ecs_task_role" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}
