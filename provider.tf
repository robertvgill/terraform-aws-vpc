provider "aws" {
  shared_credentials_file = var.credentials
  region                  = var.region
  profile                 = var.profile
}
