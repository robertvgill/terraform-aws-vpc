# Configure the AWS Provider

# AWS Region
variable "region" {
  description = "The name AWS region"
  type = string
}

# AWS credentials
variable "credentials" {
  description = "The location of the Shared Credentials file"
  default = "%AWS_SHARED_CREDENTIALS_FILE%"
//  default = "~/.aws/credentials"
}

variable "profile" {
  description = "The name of the AWS profile to use for the instance"
  type = string
}

# Environment
variable "env_name" {
  description = ""
  type        = string
}

# AWS VPC
variable "create_vpc" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = bool
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

/**
variable "vpc_cidr" {
 description = ""
 type        = map(string)
 default     = {}
}
**/

variable "cidr_prefix" {
  description = "CIDR prefix for the VPC"
  type        = string
}

variable "cidr_newbits" {
  description = "CIDR newbits for the VPC"
  type        = string
}

variable "cidr_netnum" {
  description = "CIDR netnum for the VPC"
  type        = string
}

variable "tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"
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


# DHCP Options Set
variable "enable_dhcp_options" {
  description = "Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type"
  type        = bool
}

variable "dhcp_options_domain_name" {
  description = "Specifies DNS name for DHCP options set"
  type        = string
}

variable "dhcp_options_domain_name_servers" {
  description = "Specify a list of DNS server addresses for DHCP options set"
  type        = list(string)
}

variable "dhcp_options_ntp_servers" {
  description = "Specify a list of NTP servers for DHCP options set"
  type        = list(string)
  default     = []
}

variable "dhcp_options_netbios_name_servers" {
  description = "Specify a list of netbios servers for DHCP options set"
  type        = list(string)
  default     = []
}

variable "dhcp_options_netbios_node_type" {
  description = "Specify netbios node_type for DHCP options set"
  type        = string
  default     = ""
}


# AWS ACLs


# AWS IPSec Tunnels
variable "vpn_cgw1" {
  description = ""
  type        = string
}

variable "vpn_cgw2" {
  description = ""
  type        = string
}

variable "bgp_asn1" {
  description = ""
  type        = string
}

variable "bgp_asn2" {
  description = ""
  type        = string
}

variable "vpn_ip1" {
  description = ""
  type        = string
}

variable "vpn_ip2" {
  description = ""
  type        = string
}
