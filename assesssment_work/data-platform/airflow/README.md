# Airflow DAGs (Assessment)

DAGs:
- process_sales (Glue jobs: raw->bronze, bronze->silver)
- process_customers (Glue job: raw->silver)
- process_user_profiles (manual, Glue job: raw json->silver)
- enrich_user_profiles (manual, Redshift Data API: MERGE to gold)

Required Airflow Variables (recommended):
- datalake_bucket = datalake-<account_id>-dev

Redshift params are taken from env vars (or can be moved to Variables):
- REDSHIFT_WORKGROUP
- REDSHIFT_DATABASE
- REDSHIFT_SECRET_ARN
