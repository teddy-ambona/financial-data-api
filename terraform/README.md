# Terraform deployment

- [[Optional] If you have a new AWS account](#optional-if-you-have-a-new-aws-account)
- [1 - Enter your global variables](#1---enter-your-global-variables)
- [2 - Setup remote backend](#2---setup-remote-backend)
- [3 - Create IAM user, role and policies](#3---create-iam-user-role-and-policies)
- [Module dependencies](#module-dependencies)
- [4 - Create VPC](#4---create-vpc)
- [5 - Create security groups](#5---create-security-groups)
- [6 - Create Postgres DB](#6---create-postgres-db)
- [7 - Deploy serverless web-app with ECS and Fargate](#7---deploy-serverless-web-app-with-ecs-and-fargate)

We segment environments(dev/stage/prod) using separated directories. Each directory has its own `terraform.state` file stored in s3, this is a best practice set to limit damages in case in errors. Also, the user who is running the terraform code does not need permission for the entire infrastructure but only for the resources he is trying to update.

## [Optional] If you have a new AWS account

If you already have your remote backend setup you can skip this part and jump to [3 - Create IAM user, role and policies](#3---create-iam-user-role-and-policies)

The first step will be to create a s3 bucket to store the remote backend and to create a Dynamo DB for storing the lock.

Note that if anything goes wrong and you want to start from all over again you can install [cloud-nuke](https://github.com/gruntwork-io/cloud-nuke) and run this very destructive command:

```bash
# This will destroy all resources in the specified regions
cloud-nuke aws --region=us-east-1 --region=global

# cloud-nuke does not support IAM policies yet so you might also have to remove policies in the web-console
# Github issue: https://github.com/gruntwork-io/cloud-nuke/issues/116#issuecomment-928002457
```

Configure your AWS credentials as environment variables.

> Important: You can use root user credentials for the steps 2 and 3 then you should delete the keys of the root user to comply with the [Security best practices in IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html).

In `~/.aws/credentials` (or `%UserProfile%\.aws\credentials` on Windows):

```bash
[default]
aws_access_key_id=<your access key id>
aws_secret_access_key=<your secret access key>
```

## 1 - Setup remote backend

Run the below commands to:

- create a financial-data-api-demo-state S3 bucket
- create a Dynamo DB

Update your region in terraform/live/global/s3/terragrunt.hcl, by default it is `us-east-1`

```hcl
locals {
  aws_region = "us-east-1"
}
```

```bash
cd terraform/live/global/s3

# We can omit "terragrunt init" here as terragrunt has an Auto-Init feature.

terragrunt plan
terragrunt apply
```

Now we will setup remote terraform backend by appending this to the end of `terraform/live/global/s3/terragrunt.hcl`:

```hcl
remote_state {
  backend = "s3"
  generate = {
    path      = "terragrunt_backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "financial-data-api-demo-state"
    key            = "global/s3/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "financial-data-api-demo-locks"
    encrypt        = true
  }
}
```

You can now run

```bash
$ terragrunt init

WARN[0001] The remote state S3 bucket financial-data-api-demo-state needs to be updated: 
WARN[0001]   - Bucket Root Access
WARN[0001]   - Bucket Enforced TLS
Remote state S3 bucket financial-data-api-demo-state is out of date. Would you like Terragrunt to update it? (y/n)
```

Type "y", now you should see:

```bash
Initializing the backend...
Acquiring state lock. This may take a few moments...
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "local" backend to the
  newly configured "s3" backend. No existing state was found in the newly
  configured "s3" backend. Do you want to copy this state to the new "s3"
  backend? Enter "yes" to copy and "no" to start with an empty state.

  Enter a value:
```

Type "yes"

You should now see

```bash
Releasing state lock. This may take a few moments...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.
```

## 2 - Create IAM user, role and policies

In this section, we assume that the tfstate can be stored in the bucket `financial-data-api-demo-state` under the key `global/iam/terraform.tfstate`

We will now perform the following operations:

- create a user named demo-user
- create a role
- assign role to the user
- attach policy to role(assume role policy)
- output the `aws_access_key_id` and `aws_secret_access_key` of the newly created user

```bash
cd terraform/live/global/iam

# We can omit "terragrunt init" here as terragrunt has an Auto-Init feature.

terragrunt plan
terragrunt apply
```

Then delete creds and use user credentials for creating modules.

The user credentials can be found in the JSON dictionary with `aws_iam_access_key` in the `terraform.tfstate` in s3. You can now replace them in your `~/.aws/credentials` (or `%UserProfile%\.aws\credentials` on Windows).

Note that Terraform stores the secrets in plain text in the .tfstate file, that is why is it not recommended to store it in Github but rather in S3 or other shared storage.

## Module dependencies

In the `terragrunt.hcl` of each module, we declare the dependencies on other modules so that terragrunt knows in what order to create or destroy the resources when running `terragrunt run-all apply` or `terragrunt run-all destroy`. If any of the modules fail to deploy, then Terragrunt will not attempt to deploy the modules that depend on them(cf [documentation](https://terragrunt.gruntwork.io/docs/features/execute-terraform-commands-on-multiple-modules-at-once/#dependencies-between-modules)).

```hcl
dependencies {
  paths = ["../vpc", "../security_groups", "../postgres"]
}
```

After [installing graphviz](https://installati.one/ubuntu/20.04/graphviz/) you can run:

```bash
terragrunt graph-dependencies | dot -Tsvg > graph.svg
```

<img src="../docs/img/module_dependencies.png" width="250"/>

## 3 - Create VPC

[cf terraform-aws-modules/vpc/aws](https://github.com/terraform-aws-modules/terraform-aws-vpc):

This module will:

- Create a new VPC
- Attach an internet gateway to the VPC
- Create a private subnet and a public subnet
- Create a NAT gateway
- Create a route table association

```bash
cd terraform/live/dev/vpc

terragrunt plan
terragrunt apply
```

## 4 - Create security groups (firewalls)

[cf terraform-aws-security-group](https://github.com/terraform-aws-modules/terraform-aws-security-group)

This module will:

- Create a security group for the web-server
- Create a security group for the database

```bash
cd terraform/live/dev/security-groups

terragrunt plan
terragrunt apply
```

## 5 - Create Postgres DB


## 6 - Deploy serverless web-app with ECS and Fargate
