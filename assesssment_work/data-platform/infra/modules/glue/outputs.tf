output "glue_database_name" {
  value = aws_glue_catalog_database.this.name
}

output "raw_crawler_name" {
  value = aws_glue_crawler.raw.name
}
