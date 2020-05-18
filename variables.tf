# AWS credentials
variable "profile" {
  description = "The name of the AWS profile to use for the instance"
  type        = string
}

variable "credentials" {
  description = "The location of the Shared Credentials file"
  type        = string
}

# AWS Region
variable "region" {
  description = "The name AWS region"
  type        = string
}

# Environment
variable "env_name" {
  description = ""
  type        = string
}

# AWS VPC Configuration
variable "create_vpc" {
  description = "If true, the vpc id used to launch subnets, security group and instance"
  type        = bool
}

variable "vpc_cidr" {
 description = ""
 type        = map(string)
 default     = {}
}

variable "tenancy" {
  description = "Available values: default | dedicated | host"
  type        = string
}

variable "enable_dns_support" {
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  type        = bool
  default     = false
}

variable "use_ipv6" {
  description = "If true, the specified subnet will have assigned IPv6 address block"
  type        = bool
  default     = false
}

variable "subnet_cidrs_public" {
  description = ""
  type        = list(string)
  default     = []
}

variable "subnet_cidrs_private" {
  description = ""
  type        = list(string)
  default     = []
}

variable "subnet_cidrs_database" {
  description = ""
  type        = list(string)
  default     = []
}

variable "default_tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
