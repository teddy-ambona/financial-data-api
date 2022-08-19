# data "terraform_remote_state" "db" {
#   backend = "s3"
#   config = {
#     bucket = "financial-data-api-demo"
#     key    = "data-storage/postgres/terraform.tfstate"
#     region = "us-east-2"
#   }
# }

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "3.2.0"
  name    = "my-ecs"

  container_insights = true

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
    }
  ]

  tags = {
    Environment = "Development"
  }
}
