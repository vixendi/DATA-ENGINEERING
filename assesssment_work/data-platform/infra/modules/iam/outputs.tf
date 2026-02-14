output "glue_role_arn" {
  value = aws_iam_role.glue_etl.arn
}

output "redshift_s3_role_arn" {
  value = aws_iam_role.redshift_s3_access.arn
}
