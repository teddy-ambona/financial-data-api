## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion_host_sg"></a> [bastion\_host\_sg](#module\_bastion\_host\_sg) | terraform-aws-modules/security-group/aws | ~>4.16 |
| <a name="module_db_sg"></a> [db\_sg](#module\_db\_sg) | terraform-aws-modules/security-group/aws | ~>4.16 |
| <a name="module_web_server_sg"></a> [web\_server\_sg](#module\_web\_server\_sg) | terraform-aws-modules/security-group/aws | ~>4.16 |

## Resources

| Name | Type |
|------|------|
| [terraform_remote_state.vpc](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_host_sg_id"></a> [bastion\_host\_sg\_id](#output\_bastion\_host\_sg\_id) | The ID of the bastion host security group |
| <a name="output_db_sg_id"></a> [db\_sg\_id](#output\_db\_sg\_id) | The ID of the DB security group |
| <a name="output_web_server_sg_id"></a> [web\_server\_sg\_id](#output\_web\_server\_sg\_id) | The ID of the web-server security group |
