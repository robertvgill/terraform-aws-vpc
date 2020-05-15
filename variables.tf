# Configure the AWS Provider

# AWS Region
variable "region" {
  description = "The name AWS region"
  type        = string
}

variable "credentials" {
  description = "The location of the Shared Credentials file"
  type        = string
}

variable "profile" {
  description = "The name of the AWS profile to use for the instance"
  type        = string
}

# AWS VPC Configuration
variable "env_name" {
  description = ""
  type        = string
}

variable "tenancy" {
  description = "Available values: default | dedicated | host"
  type        = string
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
 description = ""
 type        = map(string)
 default     = {}
}

variable "subnet_cidrs_public" {
  type = list(string)
  default = []
}

variable "subnet_cidrs_private" {
  type = list(string)
  default = []
}

variable "subnet_cidrs_database" {
  type = list(string)
  default = []
}

variable "default_tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
