# Create a Cloudwatch log group
resource "aws_cloudwatch_log_group" "debug_apigateway" {
  name = var.aws_log_group

  tags = {
    Terraform   = "true"
    Environment = local.environment
  }
}

# Create API Gateway
module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "~>2.2"

  create_api_domain_name = false
  name                   = "${local.environment}-http"
  description            = "My awesome HTTP API Gateway"
  protocol_type          = "HTTP"

  # Access logs
  default_stage_access_log_destination_arn = aws_cloudwatch_log_group.debug_apigateway.arn
  default_stage_access_log_format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"

  # Create VPC link
  vpc_links = {
    my-vpc = {
      name               = "example-vpc-link"
      security_group_ids = [data.terraform_remote_state.sg.outputs.api_gw_sg_id]

      # VPC link must be in private subnets
      subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets_ids
    }
  }

  # Routes and integrations
  integrations = {
    "GET /financial-data-api/{proxy+}" = {
      connection_type    = "VPC_LINK"
      vpc_link           = "my-vpc"
      integration_uri    = data.terraform_remote_state.alb.outputs.http_tcp_listener_arns[0]
      integration_type   = "HTTP_PROXY"
      integration_method = "ANY"

      # Don't forward route name ("financial-data-api") to ALB
      request_parameters = {
        "overwrite:path" = "/$request.path.proxy"
      }
    }
  }

  tags = {
    Terraform   = "true"
    Environment = local.environment
  }
}
