# Create a Cloudwatch log group
resource "aws_cloudwatch_log_group" "ecs_aws_fargate" {
  name = var.aws_log_group

  tags = {
    Terraform   = "true"
    Environment = local.environment
  }
}

# Create an ECS cluster
module "ecs" {
  source       = "terraform-aws-modules/ecs/aws"
  version      = "4.1.1"
  cluster_name = "${local.name_prefix}-ecs-fargate"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = var.aws_log_group
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }
  tags = {
    Terraform   = "true"
    Environment = local.environment
  }
}

# Get template container definition
# This task definition will tell ECS to always launch the NGINX reverse proxy container, and the
# application container on the same instance, and to link them together.
# The application container does not have a publically accessible port, so there is no way for a vulnerability
# scanning tool to directly access the application. Instead all traffic will be sent to NGINX, and NGINX is
# configured to only forward traffic to your application container
data "template_file" "app" {
  # The terragrunt_financial_data_api.json.tpl file is generated from _envcommon/financial-data-api.hcl
  template = file("./terragrunt_financial_data_api.json.tpl")
  vars = {
    aws_log_group          = var.aws_log_group
    app_image_tag          = var.app_image_tag
    app_image_repository   = var.app_image_repository
    app_container_cpu      = var.app_container_cpu
    app_container_memory   = var.app_container_memory
    nginx_image_tag        = var.nginx_image_tag
    nginx_image_repository = var.nginx_image_repository
    nginx_container_cpu    = var.nginx_container_cpu
    nginx_container_memory = var.nginx_container_memory
  }
}

# Create Task Definition
resource "aws_ecs_task_definition" "service" {
  family = "financial_data_api"

  # Set network mode to "awsvpc" so that each container is allocated an elastic network interface
  # If using the Fargate launch type, the "awsvpc" network mode is required
  # cf https://tutorialsdojo.com/ecs-network-modes-comparison/
  network_mode = "awsvpc"

  execution_role_arn       = data.terraform_remote_state.iam.outputs.ecs_task_execution_role_arn
  task_role_arn            = data.terraform_remote_state.iam.outputs.app_role_arn
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.app.rendered

  tags = {
    Terraform   = "true"
    Environment = local.environment
  }
}

# Create ECS service
resource "aws_ecs_service" "financial_data_api_service" {
  name            = "${local.name_prefix}-service"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = data.terraform_remote_state.alb.outputs.target_group_arns[0]
    container_name   = "nginx"
    container_port   = 80
  }

  network_configuration {
    security_groups  = [data.terraform_remote_state.sg.outputs.web_server_sg_id]
    subnets          = data.terraform_remote_state.vpc.outputs.public_subnets_ids
    assign_public_ip = true
  }

  tags = {
    Terraform   = "true"
    Environment = local.environment
  }
}
