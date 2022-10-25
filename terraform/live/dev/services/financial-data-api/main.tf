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
data "template_file" "app" {
  # The terragrunt_financial_data_api.json.tpl file is generated from _envcommon/financial-data-api.hcl
  template = file("./terragrunt_financial_data_api.json.tpl")
  vars = {
    dockerhub_repository = "docker.io/tambona29/financial-data-api"
    tag                  = "1.0.1"
    task_cpu             = var.task_cpu
    task_memory          = var.task_memory
    aws_log_group        = var.aws_log_group
  }
}

# Create Task Definition
resource "aws_ecs_task_definition" "service" {
  family = "financial_data_api"

  # Set network mode to "awsvpc" so that the task is allocated an elastic network interface
  # If using the Fargate launch type, the "awsvpc" network mode is required
  network_mode = "awsvpc"

  execution_role_arn       = data.terraform_remote_state.iam.outputs.ecs_service_role_arn
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