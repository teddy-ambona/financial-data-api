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
  # App
  app_image_tag        = "1.2.0-terraform-aws-deploy.dev.24fb7f417281df6c96348e083ad80394acf9cd33"
  app_image_repository = "docker.io/tambona29/financial-data-api"
  app_container_cpu    = 256 # (0.25 vCPU)
  app_container_memory = 512 # (0.5 GB)

  # Nginx
  nginx_image_tag        = "1.1.0-terraform-aws-deploy.dev.e404958dc4ba3aaec569af68a6f77e348016062b"
  nginx_image_repository = "docker.io/tambona29/nginx-demo"
  nginx_container_cpu    = 256 # (0.25 vCPU)
  nginx_container_memory = 512 # (0.5 GBs)

  # https://aws.amazon.com/premiumsupport/knowledge-center/ecs-cpu-allocation/
  task_cpu    = 512  # (0.5 vCPU)
  task_memory = 1024 # (1 GB)

  aws_log_group = "/aws/ecs/aws-fargate-demo/application-stack"
}
