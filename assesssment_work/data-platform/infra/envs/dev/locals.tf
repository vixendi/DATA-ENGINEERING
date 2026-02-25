data "aws_caller_identity" "current" {}

locals {
  project = "data-platform"
  env     = "dev"

  account_id = data.aws_caller_identity.current.account_id

  # common prefix for resource names
  name = "${local.project}-${local.env}"

  tags = {
    Project     = local.project
    Environment = local.env
    ManagedBy   = "terraform"
  }
}
