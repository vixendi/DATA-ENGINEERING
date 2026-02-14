locals {
  glue_db_name     = "${var.project_name}_glue_db"
  raw_crawler_name = "${var.project_name}-${var.env}-raw-crawler"
  raw_s3_path      = "s3://${var.datalake_bucket_name}/raw/"
}

resource "aws_glue_catalog_database" "this" {
  name = local.glue_db_name
}

resource "aws_glue_crawler" "raw" {
  name          = local.raw_crawler_name
  role          = var.glue_role_arn
  database_name = aws_glue_catalog_database.this.name

  # Всі raw-таблиці будуть з префіксом raw_
  table_prefix  = "raw_"

  s3_target {
    path = local.raw_s3_path
  }

  # Мінімум “магії” та мінімум зайвих перезаписів
  recrawl_policy {
    recrawl_behavior = "CRAWL_EVERYTHING"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "LOG"
  }

  tags = var.tags
}
