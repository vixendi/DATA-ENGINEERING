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
