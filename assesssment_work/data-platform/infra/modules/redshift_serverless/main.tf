resource "random_password" "admin" {
  length  = 24
  special = true
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_secretsmanager_secret" "admin" {
  name                    = "${var.project_name}-${var.env}-redshift-admin"
  recovery_window_in_days = 0
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "admin" {
  secret_id = aws_secretsmanager_secret.admin.id
  secret_string = jsonencode({
    username = var.admin_username
    password = random_password.admin.result
  })
}

resource "aws_redshiftserverless_namespace" "this" {
  namespace_name      = "${var.project_name}-${var.env}-ns"
  admin_username      = var.admin_username
  admin_user_password = random_password.admin.result

  iam_roles = [var.redshift_iam_role_arn]
  tags      = var.tags
}

resource "aws_security_group" "public_access" {
  name        = "${var.project_name}-${var.env}-redshift-public-sg"
  description = "Allow Redshift Serverless public access from a single CIDR"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Redshift (5439)"
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_redshiftserverless_workgroup" "this" {
  workgroup_name = "${var.project_name}-${var.env}-wg"
  namespace_name = aws_redshiftserverless_namespace.this.namespace_name

  base_capacity = 4

  publicly_accessible = true
  security_group_ids  = [aws_security_group.public_access.id]
  subnet_ids          = data.aws_subnets.default.ids

  tags = var.tags
}

# Cost guardrail (daily compute cap)
resource "aws_redshiftserverless_usage_limit" "daily_compute" {
  resource_arn  = aws_redshiftserverless_workgroup.this.arn
  usage_type    = "serverless-compute"
  amount        = 20000
  breach_action = "log"
}
