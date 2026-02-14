module "s3" {
  source       = "../../modules/s3"
  project_name = local.project
  env          = local.env
  account_id   = local.account_id
  tags         = local.tags
}

module "iam" {
  source              = "../../modules/iam"
  project_name        = local.project
  env                 = local.env
  account_id          = local.account_id
  datalake_bucket_arn = module.s3.datalake_bucket_arn
  tags                = local.tags
}

module "glue" {
  source               = "../../modules/glue"
  project_name         = local.project
  env                  = local.env
  datalake_bucket_name = module.s3.datalake_bucket_name
  glue_role_arn        = module.iam.glue_role_arn
  tags                 = local.tags
}
