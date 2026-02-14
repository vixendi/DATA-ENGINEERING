output "datalake_bucket_name" { value = aws_s3_bucket.datalake.bucket }
output "airflow_bucket_name"  { value = aws_s3_bucket.airflow.bucket }
output "logs_bucket_name"     { value = aws_s3_bucket.logs.bucket }

output "datalake_bucket_arn"  { value = aws_s3_bucket.datalake.arn }
output "airflow_bucket_arn"   { value = aws_s3_bucket.airflow.arn }
output "logs_bucket_arn"      { value = aws_s3_bucket.logs.arn }
