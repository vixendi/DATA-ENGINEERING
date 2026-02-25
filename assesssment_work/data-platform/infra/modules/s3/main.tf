locals {
  datalake_bucket_name = "datalake-${var.account_id}-${var.env}"
  airflow_bucket_name  = "airflow-${var.account_id}-${var.env}"
  logs_bucket_name     = "logs-${var.account_id}-${var.env}"
}

##################################
# DataLake Bucket
##################################
resource "aws_s3_bucket" "datalake" {
  bucket = local.datalake_bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "datalake" {
  bucket = aws_s3_bucket.datalake.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "datalake" {
  bucket = aws_s3_bucket.datalake.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "datalake" {
  bucket = aws_s3_bucket.datalake.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

# Cost guardrail: expire non-critical data in test env
resource "aws_s3_bucket_lifecycle_configuration" "datalake" {
  bucket = aws_s3_bucket.datalake.id

  rule {
    id     = "expire-test-data"
    status = "Enabled"

    filter {} # apply to whole bucket (ok for assessment)

    expiration { days = 14 }

    noncurrent_version_expiration { noncurrent_days = 14 }
  }
}

##################################
# Airflow Bucket
##################################
resource "aws_s3_bucket" "airflow" {
  bucket = local.airflow_bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "airflow" {
  bucket = aws_s3_bucket.airflow.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "airflow" {
  bucket = aws_s3_bucket.airflow.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "airflow" {
  bucket = aws_s3_bucket.airflow.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

##################################
# Logs Bucket
##################################
resource "aws_s3_bucket" "logs" {
  bucket = local.logs_bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "expire-logs"
    status = "Enabled"

    filter {}

    expiration { days = 30 }
    noncurrent_version_expiration { noncurrent_days = 30 }
  }
}
