from __future__ import annotations

import os

# MWAA/Airflow variables can override these (recommended for real MWAA):
# - Variable "glue_database"
# - Variable "glue_crawler_name"
# - Variable "redshift_workgroup"
# - Variable "redshift_database"
# - Variable "redshift_secret_arn"
# - Variable "redshift_iam_role_arn"
# - Variable "datalake_bucket"

DEFAULT_AWS_REGION = os.getenv("AWS_REGION", "us-east-1")

# Terraform outputs (dev)
GLUE_DATABASE = os.getenv("GLUE_DATABASE", "data-platform_glue_db")
GLUE_CRAWLER_NAME = os.getenv("GLUE_CRAWLER_NAME", "data-platform-dev-raw-crawler")

# Glue job names (terraform-created)
GLUE_JOB_SALES_RAW_TO_BRONZE = os.getenv("GLUE_JOB_SALES_RAW_TO_BRONZE", "data-platform-dev-sales-raw-to-bronze")
GLUE_JOB_SALES_BRONZE_TO_SILVER = os.getenv("GLUE_JOB_SALES_BRONZE_TO_SILVER", "data-platform-dev-sales-bronze-to-silver")
GLUE_JOB_CUSTOMERS_RAW_TO_SILVER = os.getenv("GLUE_JOB_CUSTOMERS_RAW_TO_SILVER", "data-platform-dev-customers-raw-to-silver")
GLUE_JOB_USER_PROFILES_RAW_TO_SILVER = os.getenv("GLUE_JOB_USER_PROFILES_RAW_TO_SILVER", "data-platform-dev-user-profiles-raw-to-silver")

# Redshift Data API params (terraform-created)
REDSHIFT_WORKGROUP = os.getenv("REDSHIFT_WORKGROUP", "data-platform-dev-wg")
REDSHIFT_DATABASE = os.getenv("REDSHIFT_DATABASE", "dev")
REDSHIFT_SECRET_ARN = os.getenv("REDSHIFT_SECRET_ARN", "")
REDSHIFT_IAM_ROLE_ARN = os.getenv("REDSHIFT_IAM_ROLE_ARN", "")

# S3
DATALAKE_BUCKET = os.getenv("DATALAKE_BUCKET", "datalake-842940822473-dev")
