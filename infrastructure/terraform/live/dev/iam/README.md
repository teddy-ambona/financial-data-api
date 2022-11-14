## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.29.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app_role"></a> [app\_role](#module\_app\_role) | terraform-aws-modules/iam/aws//modules/iam-assumable-role | ~>5.5 |
| <a name="module_ecs_task_execution_role"></a> [ecs\_task\_execution\_role](#module\_ecs\_task\_execution\_role) | terraform-aws-modules/iam/aws//modules/iam-assumable-role | ~>5.5 |
| <a name="module_iam_group_with_policies"></a> [iam\_group\_with\_policies](#module\_iam\_group\_with\_policies) | terraform-aws-modules/iam/aws//modules/iam-group-with-policies | ~> 5.3 |
| <a name="module_iam_user"></a> [iam\_user](#module\_iam\_user) | terraform-aws-modules/iam/aws//modules/iam-user | ~> 5.3 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_account_password_policy.strict](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_account_password_policy) | resource |
| [aws_iam_policy.app_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_document.mfa_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_role_arn"></a> [app\_role\_arn](#output\_app\_role\_arn) | Role to be assumed by the ECS task itself and the EC2 bastion host |
| <a name="output_ecs_task_execution_role_arn"></a> [ecs\_task\_execution\_role\_arn](#output\_ecs\_task\_execution\_role\_arn) | Role that executes ECS actions such as pulling the image and storing the application logs in cloudwatch |
