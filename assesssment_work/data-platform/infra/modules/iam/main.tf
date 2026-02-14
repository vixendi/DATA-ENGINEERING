locals {
  glue_role_name     = "${var.project_name}-${var.env}-glue-etl-role"
  redshift_role_name = "${var.project_name}-${var.env}-redshift-s3-role"

  # S3 prefixes we allow
  datalake_bucket     = var.datalake_bucket_arn
  datalake_objects    = "${var.datalake_bucket_arn}/*"

  # Optional temp prefixes for Glue/Redshift spill
  temp_prefixes = [
    "${var.datalake_bucket_arn}/tmp/*",
    "${var.datalake_bucket_arn}/athena/*"
  ]
}

##################################
# Glue ETL Role
##################################
data "aws_iam_policy_document" "glue_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "glue_etl" {
  name               = local.glue_role_name
  assume_role_policy = data.aws_iam_policy_document.glue_assume.json
  tags               = var.tags
}

data "aws_iam_policy_document" "glue_s3_access" {
  statement {
    sid    = "S3ListBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [local.datalake_bucket]
  }

  statement {
    sid    = "S3ReadWriteObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      local.datalake_objects,
      "${var.datalake_bucket_arn}/raw/*",
      "${var.datalake_bucket_arn}/bronze/*",
      "${var.datalake_bucket_arn}/silver/*",
      "${var.datalake_bucket_arn}/tmp/*"
    ]
  }
}

resource "aws_iam_policy" "glue_s3_access" {
  name   = "${var.project_name}-${var.env}-glue-s3-access"
  policy = data.aws_iam_policy_document.glue_s3_access.json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "glue_s3_access" {
  role       = aws_iam_role.glue_etl.name
  policy_arn = aws_iam_policy.glue_s3_access.arn
}

# AWS managed policy Glue needs for logs, metrics, etc.
resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_etl.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

##################################
# Redshift Serverless -> S3 Role
##################################
data "aws_iam_policy_document" "redshift_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["redshift.amazonaws.com", "redshift-serverless.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "redshift_s3_access" {
  name               = local.redshift_role_name
  assume_role_policy = data.aws_iam_policy_document.redshift_assume.json
  tags               = var.tags
}

data "aws_iam_policy_document" "redshift_s3_policy" {
  statement {
    sid     = "S3ListBucket"
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = [local.datalake_bucket]
  }

  statement {
    sid     = "S3ReadWriteForCopyUnload"
    effect  = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "${var.datalake_bucket_arn}/silver/*",
      "${var.datalake_bucket_arn}/gold/*",
      "${var.datalake_bucket_arn}/tmp/*"
    ]
  }
}

resource "aws_iam_policy" "redshift_s3_access" {
  name   = "${var.project_name}-${var.env}-redshift-s3-access"
  policy = data.aws_iam_policy_document.redshift_s3_policy.json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "redshift_s3_access" {
  role       = aws_iam_role.redshift_s3_access.name
  policy_arn = aws_iam_policy.redshift_s3_access.arn
}
