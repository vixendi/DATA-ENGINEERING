resource "aws_security_group" "mwaa" {
  name        = "${var.name}-mwaa-sg"
  description = "MWAA security group"
  vpc_id      = var.vpc_id

  # REQUIRED: allow internal traffic between MWAA components (scheduler/worker/webserver)
  ingress {
    description = "MWAA internal (self)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Web UI access from your IP
  ingress {
    description = "Airflow Web UI"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.web_ui_allowed_cidr]
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
