dependencies {
  paths = ["../../iam", "../../vpc", "../../security-groups", "../../data-storage/rds", "../../route53", "../../alb"]
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

variable "aws_log_group" {
  type        = string
  description = "Log group for the application"
}

variable "app_container_cpu" {
  type        = number
  description = "Number of vCPU for the app container"
}

variable "app_container_memory" {
  type        = number
  description = "Number of vMemory for the app container"
}

variable "app_image_tag" {
  type        = string
  description = "App Docker image tag"
}

variable "app_image_repository" {
  type        = string
  description = "App image repository"
}

variable "nginx_container_cpu" {
  type        = number
  description = "Number of vCPU for the Nginx container"
}

variable "nginx_container_memory" {
  type        = number
  description = "Number of vMemory for the Nginx container"
}

variable "nginx_image_tag" {
  type        = string
  description = "Nginx Docker image tag"
}

variable "nginx_image_repository" {
  type        = string
  description = "Nginx image repository"
}

variable "task_memory" {
  type        = string
  description = "Total memory allocated for the task"
}

variable "task_cpu" {
  type        = string
  description = "Total number of vCPU allocated for the task"
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

# Allow fetching ALB ARN from the state file
data "terraform_remote_state" "alb" {
  backend = "s3"

  config = {
    bucket = "${local.env_vars.locals.remote_state_bucket}"
    region = "${local.env_vars.locals.aws_region}"
    key = "${local.env_vars.locals.environment}/alb/terraform.tfstate"
  }
}
EOF
}

# Automate generation of task template.
# Set PYTHONDONTWRITEBYTECODE and PYTHONUNBUFFERED to 1 so that logs aren't buffered
# and can be observed in real-time (useful for troubleshooting issues)
generate "task_template" {
  path              = "terragrunt_financial_data_api.json.tpl"
  if_exists         = "overwrite"
  disable_signature = true
  contents          = <<EOF
[
    {
    "name": "nginx",
    "image": "$${nginx_image_repository}:$${nginx_image_tag}",
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${local.env_vars.locals.aws_region}",
        "awslogs-stream-prefix": "nginx",
        "awslogs-group": "$${aws_log_group}"
      }
    },
    "portMappings": [
      {
        "containerPort": 80,
        "protocol": "tcp"
      }
    ],
    "cpu": $${nginx_container_cpu},
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 65536,
        "hardLimit": 65536
      }
    ],
    "memory": $${nginx_container_memory}
  },
  {
    "name": "flask-app",
    "image": "$${app_image_repository}:$${app_image_tag}",
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${local.env_vars.locals.aws_region}",
        "awslogs-stream-prefix": "app-server",
        "awslogs-group": "$${aws_log_group}"
      }
    },
    "portMappings": [
      {
        "containerPort": 5000,
        "protocol": "tcp"
      }
    ],
    "cpu": $${app_container_cpu},
    "environment": [
      {
        "name": "ENVIRONMENT",
        "value": "${local.env_vars.locals.environment}"
      },
      {
        "name": "AWS_DEFAULT_REGION",
        "value": "${local.env_vars.locals.aws_region}"
      },
      {
        "name": "PYTHONDONTWRITEBYTECODE",
        "value": "1"
      },
      {
        "name": "PYTHONUNBUFFERED",
        "value": "1"
      }
    ],
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 65536,
        "hardLimit": 65536
      }
    ],
    "memory": $${app_container_memory}
  }
]
EOF
}
