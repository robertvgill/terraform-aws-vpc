provider "aws" {
    profile                 = var.profile
    shared_credentials_file = var.credentials
    region                  = var.region
}
