dependencies {
  paths = ["../../vpc", "../../security-groups", "../../data-storage"]
}

locals {
  # Automatically load environment-level variables
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

generate "common" {
  path      = "terragrunt_common.tf"
  if_exists = "overwrite"
  contents  = <<EOF
locals {
  # use short name if possible, because some resources have length limit on its name.
  name_prefix    = "${local.env_vars.locals.application}-${local.env_vars.locals.environment}"

  environment    = "${local.env_vars.locals.environment}"
}

variable "task_cpu" {
  type        = number
  description = "Number of vCPU for the task"
}

variable "task_memory" {
  type        = number
  description = "Number of vMemory for the task"
}

variable "aws_log_group" {
  type        = string
  description = "Log group for the task"
}

variable "image_tag" {
  type        = string
  description = "Docker image tag"
}

variable "image_repository" {
  type        = string
  description = "Image repository"
}

# Allow fetching security-group id from the state file
data "terraform_remote_state" "sg" {
  backend = "s3"

  config = {
    bucket = "${local.env_vars.locals.remote_state_bucket}"
    region = "${local.env_vars.locals.aws_region}"
    key = "${local.env_vars.locals.environment}/security-groups/terraform.tfstate"
  }
}

# Allow fetching role ARN from the state file
data "terraform_remote_state" "iam" {
  backend = "s3"

  config = {
    bucket = "${local.env_vars.locals.remote_state_bucket}"
    region = "${local.env_vars.locals.aws_region}"
    key = "global/iam/terraform.tfstate"
  }
}

# Allow fetching VPC id from the state file
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "${local.env_vars.locals.remote_state_bucket}"
    region = "${local.env_vars.locals.aws_region}"
    key = "${local.env_vars.locals.environment}/vpc/terraform.tfstate"
  }
}
EOF
}

# Automate generation of task template
generate "task_template" {
  path              = "terragrunt_financial_data_api.json.tpl"
  if_exists         = "overwrite"
  disable_signature = true
  contents          = <<EOF
[
  {
    "name": "financial_data_api",
    "image": "$${image_repository}:$${image_tag}",
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${local.env_vars.locals.aws_region}",
        "awslogs-stream-prefix": "financial-data-api-service",
        "awslogs-group": "$${aws_log_group}"
      }
    },
    "portMappings": [
      {
        "containerPort": 5000,
        "hostPort": 5000,
        "protocol": "tcp"
      }
    ],
    "cpu": $${task_cpu},
    "environment": [
      {
        "name": "ENVIRONMENT",
        "value": "${local.env_vars.locals.environment}"
      },
      {
        "name": "AWS_DEFAULT_REGION",
        "value": "${local.env_vars.locals.aws_region}"
      }
    ],
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 65536,
        "hardLimit": 65536
      }
    ],
    "mountPoints": [],
    "memory": $${task_memory},
    "volumesFrom": []
  }
]
EOF
}
