# This ALB is accessed only via VPC link so this tfsec issue can be ignored.
#tfsec:ignore:aws-elb-http-not-used
module "ecs_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "demo-alb"

  load_balancer_type = "application"

  # Make the ALB internally facing
  internal        = true
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets         = data.terraform_remote_state.vpc.outputs.private_subnets_ids
  security_groups = [data.terraform_remote_state.sg.outputs.alb_sg_id]

  access_logs = {
    bucket = "${local.environment}-financial-data-api-demo-alb-logs"
  }

  # Configure target group
  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"

      # Set healthcheck with 30 seconds interval
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/_healthcheck"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  ]

  # Create listener
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      type               = "forward"
      target_group_index = 0
    }
  ]

  # cf https://aquasecurity.github.io/tfsec/v1.28.0/checks/aws/elb/drop-invalid-headers/
  drop_invalid_header_fields = true

  tags = {
    Terraform   = "true"
    Environment = local.environment
  }
}
