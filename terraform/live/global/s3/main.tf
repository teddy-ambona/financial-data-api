# Create S3 bucket for storing the .tfstate file
resource "aws_s3_bucket" "financial_data_api_demo_state" {
  bucket = "financial-data-api-demo-state"
}

# Enable versioning so we can see the full revision history of our state files
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.financial_data_api_demo_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Ensure that your state files, and any secrets they may contain, are always encrypted on disk when stored in S3.
resource "aws_s3_bucket_server_side_encryption_configuration" "sse_config" {
  bucket = aws_s3_bucket.financial_data_api_demo_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Create Dynamo DB table for storing lock ID
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "financial-data-api-demo-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }
}
