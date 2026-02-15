module "network_mwaa" {
  source   = "../../modules/network_mwaa"
  name     = local.name
  vpc_cidr = "10.60.0.0/16"
  az_count = 2
  tags     = local.tags
}
