## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.37.0 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs"></a> [ecs](#module\_ecs) | terraform-aws-modules/ecs/aws | 4.1.1 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.ecs_aws_fargate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_service.financial_data_api_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [template_file.app](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [terraform_remote_state.alb](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.iam](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.sg](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [terraform_remote_state.vpc](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_container_cpu"></a> [app\_container\_cpu](#input\_app\_container\_cpu) | Number of vCPU for the app container | `number` | n/a | yes |
| <a name="input_app_container_memory"></a> [app\_container\_memory](#input\_app\_container\_memory) | Number of vMemory for the app container | `number` | n/a | yes |
| <a name="input_app_image_repository"></a> [app\_image\_repository](#input\_app\_image\_repository) | App image repository | `string` | n/a | yes |
| <a name="input_app_image_tag"></a> [app\_image\_tag](#input\_app\_image\_tag) | App Docker image tag | `string` | n/a | yes |
| <a name="input_aws_log_group"></a> [aws\_log\_group](#input\_aws\_log\_group) | Log group for the application | `string` | n/a | yes |
| <a name="input_nginx_container_cpu"></a> [nginx\_container\_cpu](#input\_nginx\_container\_cpu) | Number of vCPU for the Nginx container | `number` | n/a | yes |
| <a name="input_nginx_container_memory"></a> [nginx\_container\_memory](#input\_nginx\_container\_memory) | Number of vMemory for the Nginx container | `number` | n/a | yes |
| <a name="input_nginx_image_repository"></a> [nginx\_image\_repository](#input\_nginx\_image\_repository) | Nginx image repository | `string` | n/a | yes |
| <a name="input_nginx_image_tag"></a> [nginx\_image\_tag](#input\_nginx\_image\_tag) | Nginx Docker image tag | `string` | n/a | yes |
| <a name="input_task_cpu"></a> [task\_cpu](#input\_task\_cpu) | Total number of vCPU allocated for the task | `string` | n/a | yes |
| <a name="input_task_memory"></a> [task\_memory](#input\_task\_memory) | Total memory allocated for the task | `string` | n/a | yes |

## Outputs

No outputs.
