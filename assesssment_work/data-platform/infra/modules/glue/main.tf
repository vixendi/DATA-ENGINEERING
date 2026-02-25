locals {
  glue_db_name     = "${var.project_name}_glue_db"
  raw_crawler_name = "${var.project_name}-${var.env}-raw-crawler"

  s3_customers_path    = "s3://${var.datalake_bucket_name}/raw/customers/"
  s3_sales_path        = "s3://${var.datalake_bucket_name}/raw/sales/"
  s3_user_profiles_path = "s3://${var.datalake_bucket_name}/raw/user_profiles/"
}

resource "aws_glue_catalog_database" "this" {
  name = local.glue_db_name
}

# Single crawler with 3 S3 targets (customers, sales, user_profiles)
resource "aws_glue_crawler" "raw" {
  name          = local.raw_crawler_name
  role          = var.glue_role_arn
  database_name = aws_glue_catalog_database.this.name

  table_prefix = "raw_"

  s3_target { path = local.s3_customers_path }
  s3_target { path = local.s3_sales_path }
  s3_target { path = local.s3_user_profiles_path }

  recrawl_policy {
    recrawl_behavior = "CRAWL_EVERYTHING"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "LOG"
  }

  tags = var.tags
}
