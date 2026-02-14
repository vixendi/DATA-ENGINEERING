output "glue_database_name" {
  value = aws_glue_catalog_database.this.name
}

output "raw_crawler_name" {
  value = aws_glue_crawler.raw.name
}

output "job_sales_raw_to_bronze"     { value = aws_glue_job.sales_raw_to_bronze.name }
output "job_sales_bronze_to_silver"  { value = aws_glue_job.sales_bronze_to_silver.name }
output "job_customers_raw_to_silver" { value = aws_glue_job.customers_raw_to_silver.name }
output "job_profiles_raw_to_silver"  { value = aws_glue_job.profiles_raw_to_silver.name }
