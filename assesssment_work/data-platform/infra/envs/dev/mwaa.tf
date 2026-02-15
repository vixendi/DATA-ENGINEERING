module "mwaa" {
  source = "../../modules/mwaa"
  name   = local.name
  tags   = local.tags

  airflow_bucket_name = module.s3.airflow_bucket_name
  dag_s3_path         = "dags"

  vpc_id     = module.network_mwaa.vpc_id
  subnet_ids = module.network_mwaa.private_subnet_ids

  # IMPORTANT: MWAA micro requires scheduler count = 1
  schedulers = 1

  environment_class = "mw1.micro"
  min_workers       = 1
  max_workers       = 1

  webserver_access_mode = "PUBLIC_ONLY"

  # Use a supported version; MWAA supports Airflow 2.11 (Jan 2026).
  airflow_version     = "2.11.0"
  web_ui_allowed_cidr = "91.150.213.168/32"
}
