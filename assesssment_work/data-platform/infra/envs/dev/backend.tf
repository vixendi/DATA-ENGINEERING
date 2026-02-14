terraform {
  backend "s3" {
    bucket  = "tfstate-842940822473-data-platform-dev"
    key     = "data-platform/dev/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
