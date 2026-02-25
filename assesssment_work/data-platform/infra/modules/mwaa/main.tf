data "aws_region" "current" {}

resource "aws_security_group" "mwaa" {
  name        = "${var.name}-mwaa-sg"
  description = "MWAA security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "Airflow Web UI"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.web_ui_allowed_cidr]
  }

  # allow internal VPC HTTPS (helps ALB/health checks in some setups)
  ingress {
    description = "VPC HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.60.0.0/16"]
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-mwaa-sg" })
}

resource "aws_iam_role" "mwaa_exec" {
  name = "${var.name}-mwaa-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = [
          "airflow.amazonaws.com",
          "airflow-env.amazonaws.com"
        ]
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = merge(var.tags, { Name = "${var.name}-mwaa-exec-role" })
}

# "No-gymnastics" policy: give full admin to avoid MWAA validation failures (TEMP for assessment)
resource "aws_iam_role_policy_attachment" "admin" {
  role       = aws_iam_role.mwaa_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Add explicit S3Control checks that MWAA does during validation
resource "aws_iam_role_policy" "mwaa_exec_inline" {
  name = "${var.name}-mwaa-exec-inline"
  role = aws_iam_role.mwaa_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3DagsRead"
        Effect = "Allow"
        Action = ["s3:GetObject","s3:ListBucket","s3:GetBucketPublicAccessBlock"]
        Resource = [
          "arn:aws:s3:::${var.airflow_bucket_name}",
          "arn:aws:s3:::${var.airflow_bucket_name}/*"
        ]
      },
      {
        Sid    = "S3ControlChecks"
        Effect = "Allow"
        Action = ["s3:GetAccountPublicAccessBlock"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_mwaa_environment" "this" {
  name                = "${var.name}-mwaa"
  airflow_version     = var.airflow_version
  environment_class   = var.environment_class

  source_bucket_arn   = "arn:aws:s3:::${var.airflow_bucket_name}"
  dag_s3_path         = var.dag_s3_path
  execution_role_arn  = aws_iam_role.mwaa_exec.arn

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

  tags = merge(var.tags, { Name = "${var.name}-mwaa" })
}
