data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = "financial-data-api-demo"
    key    = "data-storage/postgres/terraform.tfstate"
    region = "us-east-2"
  }
}
