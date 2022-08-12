dependencies {
  paths = ["../vpc"]
}

generate "common" {
  path = "terragrunt_common.tf"
  if_exists = "overwrite"
  contents = <<EOF
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type = number
  default = 8080
}

variable "application" {
  description = "application name"
  # use short name if possible, because some resources have length limit on its name.
  default = "api-demo"
}

variable "environment" {
  description = "environment name"
  type        = string
}

locals {
  name_prefix    = "${var.application}-${var.environment}"
}

# Allow fetching VPC id from the state file
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "${var.remote_state_bucket}"
    region = "${var.aws_region}"
    key = "${var.environment}/security_groups/terraform.tfstate"
  }
}
EOF
}
