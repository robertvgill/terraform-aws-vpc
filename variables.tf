// AWS Credentials
variable "credentials" {
//  default = "~/.aws/credentials"
  default = "%AWS_SHARED_CREDENTIALS_FILE%"
}

// AWS Profile
variable "profile" {
  default = "personal"
}

// AWS Region
variable "region" {
  default = "ap-southeast-1"
}

//AWS VPC Configuration
variable "vpc_name" {
  default = "vpc-stage"
}

variable "vpc_cidr" {
  type = map

  default = {
    cidr_block = "10.111.0.0/16"
    newbits    = "6"
    netnum     = "1"
  }
}
/**
variable "availability_zones" {
  type = list

  default = [
    "ap-southeast-1a",
    "ap-southeast-1b",
    "ap-southeast-1c"
  ]
}
**/
variable "subnet_cidrs_public" {
  type = list

  default = [
    "10.111.0.0/24",
    "10.111.4.0/24",
    "10.111.8.0/24"]
}

variable "subnet_cidrs_private" {
  type = list
  default = [
    "10.111.12.0/24",
    "10.111.16.0/24",
    "10.111.20.0/24"]
}

variable "use_ipv6" {
  default     = false
  description = "If true, the specified subnet will have assigned IPv6 address block."
}

variable "tenancy" {
  default     = "default"
  description = "Available values: default | dedicated | host"
}

variable nat_gateway_ips {
  default = {
  "0" = "10.111.0.1"
  "1" = "10.111.4.1"
  "2" = "10.111.8.1"
  }
}
