# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that helps keep your code DRY and
# maintainable: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# Include configurations that are common used across multiple environments.
# ---------------------------------------------------------------------------------------------------------------------

# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# components and environments, such as how to configure remote state.

include "root" {
  path = find_in_parent_folders()
}

# Include the envcommon configuration for the component. The envcommon configuration contains settings that are common
# for the component across all environments.
include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/financial-data-api.hcl"
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

# For development, we want to specify smaller instance classes and storage, so we specify override parameters here. These
# inputs get merged with the common inputs from the root and the envcommon terragrunt.hcl
inputs = {
  image_tag        = "1.1.0-terraform-aws-deploy.dev.bafdfe50e2d766e3b113bfa377dae0a035bda2cc"
  image_repository = "docker.io/tambona29/financial-data-api"
  task_cpu         = 256 # (.25 vCPU)
  task_memory      = 512 # (512 MB)
  aws_log_group    = "/aws/ecs/aws-fargate"
}
