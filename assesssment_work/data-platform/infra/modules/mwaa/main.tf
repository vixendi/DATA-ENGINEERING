data "aws_region" "current" {}


resource "aws_iam_role" "mwaa_exec" {
  name = "${var.name}-mwaa-exec-role"

  # MWAA requires airflow-env.amazonaws.com as service principal (AWS validation)
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = [
          "airflow.amazonaws.com",
          "airflow-env.amazonaws.com"
        ]
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

data "template_file" "exec_policy" {
  template = file("${path.module}/policies/mwaa_exec_policy.json")
  vars = {
    airflow_bucket = var.airflow_bucket_name
  }
}

resource "aws_iam_role_policy" "mwaa_exec_inline" {
  name   = "${var.name}-mwaa-exec-inline"
  role   = aws_iam_role.mwaa_exec.id
  policy = data.template_file.exec_policy.rendered
}

resource "aws_mwaa_environment" "this" {
  name               = "${var.name}-mwaa"
  airflow_version    = var.airflow_version
  environment_class  = var.environment_class
  execution_role_arn = aws_iam_role.mwaa_exec.arn

  source_bucket_arn = "arn:aws:s3:::${var.airflow_bucket_name}"
  dag_s3_path       = var.dag_s3_path

  webserver_access_mode = var.webserver_access_mode

  min_workers = var.min_workers
  max_workers = var.max_workers
  schedulers  = var.schedulers

  network_configuration {
    security_group_ids = [aws_security_group.mwaa.id]
    subnet_ids         = var.subnet_ids
  }

  logging_configuration {
    dag_processing_logs {
      enabled   = true
      log_level = "WARNING"
    }

    scheduler_logs {
      enabled   = true
      log_level = "WARNING"
    }

    task_logs {
      enabled   = true
      log_level = "WARNING"
    }

    webserver_logs {
      enabled   = true
      log_level = "ERROR"
    }

    worker_logs {
      enabled   = true
      log_level = "WARNING"
    }
  }

  tags = var.tags
}
