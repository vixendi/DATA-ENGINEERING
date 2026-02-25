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
  scripts_prefix       = "s3://${module.s3.datalake_bucket_name}/scripts/glue/jobs"
  tags                 = local.tags
}

module "redshift" {
  source = "../../modules/redshift_serverless"

  project_name = local.project
  env          = local.env
  tags         = local.tags

  admin_username = "admin"
  allowed_cidr   = "162.120.187.35/32"

  redshift_iam_role_arn = module.iam.redshift_s3_role_arn
}
