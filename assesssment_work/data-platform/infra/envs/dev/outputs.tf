output "DataLakeBucketName" { value = module.s3.datalake_bucket_name }
output "AirflowBucketName" { value = module.s3.airflow_bucket_name }
output "LogsBucketName" { value = module.s3.logs_bucket_name }

output "GlueRoleArn" {
  value = module.iam.glue_role_arn
}

output "RedshiftS3RoleArn" {
  value = module.iam.redshift_s3_role_arn
}

output "GlueDatabaseName" {
  value = module.glue.glue_database_name
}

output "GlueCrawlerName" {
  value = module.glue.raw_crawler_name
}

output "GlueJobSalesRawToBronze" { value = module.glue.job_sales_raw_to_bronze }
output "GlueJobSalesBronzeToSilver" { value = module.glue.job_sales_bronze_to_silver }
output "GlueJobCustomersRawToSilver" { value = module.glue.job_customers_raw_to_silver }
output "GlueJobUserProfilesRawToSilver" { value = module.glue.job_profiles_raw_to_silver }

output "RedshiftWorkgroupEndpoint" { value = module.redshift.endpoint }
output "RedshiftSecretArn" { value = module.redshift.secret_arn }
output "RedshiftNamespaceName" { value = module.redshift.namespace_name }
output "RedshiftWorkgroupName" { value = module.redshift.workgroup_name }

output "MWAAName" { value = module.mwaa.name }
output "MWAAWebserverUrl" { value = module.mwaa.webserver_url }
output "MWAAExecRoleArn" { value = module.mwaa.exec_role_arn }
