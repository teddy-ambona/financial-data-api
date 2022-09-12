resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10

  tags = {
    Terraform   = "true"
    Environment = "global"
  }

}

# Create S3 bucket for storing the .tfstate file
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.4"

  bucket = "financial-data-api-demo-state"

  # S3 Access block should restrict public bucket to limit access
  # cf https://aquasecurity.github.io/tfsec/v1.27.1/checks/aws/s3/no-public-buckets/
  restrict_public_buckets = true

  # S3 buckets should ignore public ACLs on buckets and any objects they contain.
  # By ignoring rather than blocking, PUT calls with public ACLs will still be applied but the ACL will be ignored.
  # cf https://aquasecurity.github.io/tfsec/v1.27.1/checks/aws/s3/ignore-public-acls/
  ignore_public_acls = true

  # S3 buckets should block public ACLs on buckets and any objects they contain.
  # By blocking, PUTs with fail if the object has any public ACL.
  # cf https://aquasecurity.github.io/tfsec/v1.27.1/checks/aws/s3/block-public-acls/
  block_public_acls = true

  # S3 bucket policy should have block public policy to prevent users from putting a policy that enable public access.
  # cf https://aquasecurity.github.io/tfsec/v1.27.1/checks/aws/s3/block-public-policy/
  block_public_policy = true

  # Ensure that your state files, and any secrets they may contain, are always encrypted on disk when stored in S3.
  server_side_encryption_configuration = {
    rule = {
      # Amazon S3 Bucket Keys reduce the request costs of Amazon S3 server-side encryption (SSE) with
      # AWS Key Management Service (KMS) by up to 99% by decreasing the request traffic from S3 to KMS
      # cf https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-key.html
      bucket_key_enabled = true

      # S3 encryption should use Customer Managed Keys
      # cf https://aquasecurity.github.io/tfsec/v1.27.1/checks/aws/s3/encryption-customer-key/
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.mykey.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  # Enable versioning so we can see the full revision history of our state files
  versioning = {
    enabled = true
  }

  tags = {
    Terraform   = "true"
    Environment = "global"
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

  tags = {
    Terraform   = "true"
    Environment = "global"
  }

}
