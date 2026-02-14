module "s3" {
  source       = "../../modules/s3"
  project_name = local.project
  env          = local.env
  account_id   = local.account_id
  tags         = local.tags
}
