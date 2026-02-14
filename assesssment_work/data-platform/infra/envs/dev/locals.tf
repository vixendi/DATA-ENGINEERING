locals {
  project    = "data-platform"
  env        = "dev"
  account_id = "842940822473"

  tags = {
    Project     = local.project
    Environment = local.env
    ManagedBy   = "terraform"
  }
}
