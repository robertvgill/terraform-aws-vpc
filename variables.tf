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

variable "env_name" {
  type        = string
  default     = "stg"
}

//AWS VPC Configuration
variable "vpc_name" {
  type        = string
  default     = "vpc"
}

variable "enable_dns_hostnames" {
  type        = bool
  default     = false
}

variable "enable_dns_support" {
  type        = bool
  default     = true
}

variable "enable_ipv6" {
  type        = bool
  default     = false
}

variable "vpc_cidr" {
  type = map

  default = {
    cidr_block = "10.111.0.0/16"
    newbits    = "6"
    netnum     = "1"
  }
}

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

variable "subnet_cidrs_database" {
  type = list
  default = [
    "10.111.24.0/24",
    "10.111.28.0/24",
    "10.111.32.0/24"]
}

variable "tenancy" {
  default     = "default"
  description = "Available values: default | dedicated | host"
}

variable "nat_gateway_ips" {
  default = {
  "0" = "10.111.0.1"
  "1" = "10.111.4.1"
  "2" = "10.111.8.1"
  }
}

variable "default_tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {
    env       : "Stage",
    department: "DSS",
    team      : "Digital Engagement"
  }
}

variable "vpc_tags" {
  type        = map(string)
  default     = {}
}

variable "igw_tag" {
  type        = string
  default     = "igw-stage"
}
