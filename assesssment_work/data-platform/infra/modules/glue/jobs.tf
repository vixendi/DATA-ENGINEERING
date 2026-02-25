locals {
  bronze_sales_path     = "s3://${var.datalake_bucket_name}/bronze/sales/"
  silver_sales_path     = "s3://${var.datalake_bucket_name}/silver/sales/"
  silver_customers_path = "s3://${var.datalake_bucket_name}/silver/customers/"
  silver_profiles_path  = "s3://${var.datalake_bucket_name}/silver/user_profiles/"

  script_sales_raw_to_bronze     = "${var.scripts_prefix}/sales_raw_to_bronze.py"
  script_sales_bronze_to_silver  = "${var.scripts_prefix}/sales_bronze_to_silver.py"
  script_customers_raw_to_silver = "${var.scripts_prefix}/customers_raw_to_silver.py"
  script_profiles_raw_to_silver  = "${var.scripts_prefix}/user_profiles_raw_to_silver.py"
}

# Cost guardrails: Glue 4.0, 2x G.1X, short timeout
locals {
  glue_version       = "4.0"
  worker_type        = "G.1X"
  number_of_workers  = 2
  timeout_minutes    = 15
  max_retries        = 1
}

resource "aws_glue_job" "sales_raw_to_bronze" {
  name     = "${var.project_name}-${var.env}-sales-raw-to-bronze"
  role_arn = var.glue_role_arn

  glue_version      = local.glue_version
  worker_type       = local.worker_type
  number_of_workers = local.number_of_workers
  timeout           = local.timeout_minutes
  max_retries       = local.max_retries

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = local.script_sales_raw_to_bronze
  }

  default_arguments = {
    "--database" = aws_glue_catalog_database.this.name
    "--table"    = "raw_sales"
    "--out_path" = local.bronze_sales_path
    "--enable-metrics" = "true"
  }

  tags = var.tags
}

resource "aws_glue_job" "sales_bronze_to_silver" {
  name     = "${var.project_name}-${var.env}-sales-bronze-to-silver"
  role_arn = var.glue_role_arn

  glue_version      = local.glue_version
  worker_type       = local.worker_type
  number_of_workers = local.number_of_workers
  timeout           = local.timeout_minutes
  max_retries       = local.max_retries

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = local.script_sales_bronze_to_silver
  }

  default_arguments = {
    "--in_path"  = local.bronze_sales_path
    "--out_path" = local.silver_sales_path
    "--enable-metrics" = "true"
  }

  tags = var.tags
}

resource "aws_glue_job" "customers_raw_to_silver" {
  name     = "${var.project_name}-${var.env}-customers-raw-to-silver"
  role_arn = var.glue_role_arn

  glue_version      = local.glue_version
  worker_type       = local.worker_type
  number_of_workers = local.number_of_workers
  timeout           = local.timeout_minutes
  max_retries       = local.max_retries

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = local.script_customers_raw_to_silver
  }

  default_arguments = {
    "--database" = aws_glue_catalog_database.this.name
    "--table"    = "raw_customers"
    "--out_path" = local.silver_customers_path
    "--enable-metrics" = "true"
  }

  tags = var.tags
}

resource "aws_glue_job" "profiles_raw_to_silver" {
  name     = "${var.project_name}-${var.env}-user-profiles-raw-to-silver"
  role_arn = var.glue_role_arn

  glue_version      = local.glue_version
  worker_type       = local.worker_type
  number_of_workers = local.number_of_workers
  timeout           = local.timeout_minutes
  max_retries       = local.max_retries

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = local.script_profiles_raw_to_silver
  }

  default_arguments = {
    "--database" = aws_glue_catalog_database.this.name
    "--table"    = "raw_user_profiles_json"
    "--out_path" = local.silver_profiles_path
    "--enable-metrics" = "true"
  }

  tags = var.tags
}
