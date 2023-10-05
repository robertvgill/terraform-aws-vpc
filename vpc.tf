# S3 Remote State File
terraform {
  backend "s3" {}
}

# AWS Availability Zones
data "aws_availability_zones" "all" {
  state = "available"
}

# VPC
resource "aws_vpc" "vpc" {
//  count = var.create_vpc ? 1 : 0

  cidr_block                       = var.cidr_prefix
  instance_tenancy                 = var.tenancy

  enable_dns_support               = var.enable_dns_support
  enable_dns_hostnames             = var.enable_dns_hostnames

  assign_generated_ipv6_cidr_block = var.use_ipv6

  tags = merge(
    {
      "Name" = "${var.env_name}-vpc"
    },
    var.default_tags
  )
}

# DHCP Options Set
resource "aws_vpc_dhcp_options" "vpc" {
  count = var.enable_dhcp_options ? 1 : 0

  domain_name          = var.dhcp_options_domain_name
  domain_name_servers  = var.dhcp_options_domain_name_servers
  ntp_servers          = var.dhcp_options_ntp_servers
  netbios_name_servers = var.dhcp_options_netbios_name_servers
  netbios_node_type    = var.dhcp_options_netbios_node_type

  tags = merge(
    {
      "Name" = "${var.env_name}-dhcp"
    },
    var.default_tags
  )
}

# DHCP Options Set Association
resource "aws_vpc_dhcp_options_association" "vpc" {
  count = var.enable_dhcp_options ? 1 : 0

  vpc_id          = aws_vpc.vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.vpc[0].id
}


# Public Subnets
resource "aws_subnet" "public" {
  count             = length(data.aws_availability_zones.all.names)

  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(data.aws_availability_zones.all.names, count.index)

//  cidr_block        = element(var.subnet_cidrs_public, count.index)
  cidr_block        = cidrsubnet(var.cidr_prefix, var.cidr_newbits, 1 * count.index + 0)

  map_public_ip_on_launch = true
/**
  ipv6_cidr_block                 = "${var.use_ipv6 == 0 ? "" : cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, var.vpc["newbits"], count.index + 1)}"
  assign_ipv6_address_on_creation = "${var.use_ipv6}"
**/
  tags = merge(
    {
      "Name" = "${var.env_name}-public-az${count.index + 1}"
    },
    var.default_tags
  )
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = length(data.aws_availability_zones.all.names)

  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(data.aws_availability_zones.all.names, count.index)

//  cidr_block        = element(var.subnet_cidrs_private, count.index)
  cidr_block        = cidrsubnet(var.cidr_prefix, var.cidr_newbits, 1 * count.index + 3)

  map_public_ip_on_launch = false
/**
  ipv6_cidr_block                 = "${var.use_ipv6 == 0 ? "" : cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, var.vpc["newbits"], count.index + 100)}"
  assign_ipv6_address_on_creation = "${var.use_ipv6}"
**/

tags = merge(
    {
      "Name" = "${var.env_name}-private-az${count.index + 1}"
    },
    var.default_tags
  )
}

# Database Subnets
resource "aws_subnet" "database" {
  count             = length(data.aws_availability_zones.all.names)

  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(data.aws_availability_zones.all.names, count.index)

//  cidr_block        = element(var.subnet_cidrs_database, count.index)
  cidr_block        = cidrsubnet(var.cidr_prefix, var.cidr_newbits, 1 * count.index + 6)

  map_public_ip_on_launch = false
/**
  ipv6_cidr_block                 = "${var.use_ipv6 == 0 ? "" : cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, var.vpc["newbits"], count.index + 100)}"
  assign_ipv6_address_on_creation = "${var.use_ipv6}"
**/

tags = merge(
    {
      "Name" = "${var.env_name}-database-az${count.index + 1}"
    },
    var.default_tags
  )
}


# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    {
      "Name" = "${var.env_name}-igw"
    },
    var.default_tags
  )
}

resource "aws_egress_only_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    {
      "Name" = "${var.env_name}-eigw"
    },
    var.default_tags
  )
}


# NAT Gateways
resource "aws_eip" "nat" {
//  count      = length(data.aws_availability_zones.all.names)

  vpc        = true

  tags = merge(
      {
//        "Name" = format("%s-nat-az%d", var.env_name, count.index + 1)
        "Name" = var.env_name
      },
      var.default_tags
    )
}

resource "aws_nat_gateway" "nat" {
//  count         = length(data.aws_availability_zones.all.names)

//  allocation_id = element(aws_eip.nat.*.id, count.index)
//  subnet_id     = element(aws_subnet.public.*.id, count.index)

  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  depends_on    = [aws_internet_gateway.igw]

  tags = merge(
      {
//        "Name" = format("%s-nat-az%d", var.env_name, count.index + 1)
        "Name" = var.env_name
      },
      var.default_tags
    )
}


# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  propagating_vgws = [aws_vpn_gateway.vpn_gateway.id]

  tags = merge(
      {
        "Name" = "${var.env_name}-public-rtb"
      },
      var.default_tags
    )
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}


resource "aws_route_table" "private" {
  count  = length(data.aws_availability_zones.all.names)

  vpc_id = aws_vpc.vpc.id
  propagating_vgws = [aws_vpn_gateway.vpn_gateway.id]

  tags = merge(
      {
        "Name" = format("%s-private-rtb-az%d", var.env_name, count.index + 1)
      },
      var.default_tags
    )
}

resource "aws_route" "private" {
  count                  = length(data.aws_availability_zones.all.names)

  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat.*.id, count.index)
}


resource "aws_route_table" "database" {
  count  = length(data.aws_availability_zones.all.names)

  vpc_id = aws_vpc.vpc.id
  propagating_vgws = [aws_vpn_gateway.vpn_gateway.id]

  tags = merge(
      {
        "Name" = format("%s-database-rtb-az%d", var.env_name, count.index + 1)
      },
      var.default_tags
    )
}

resource "aws_route" "database" {
  count                  = length(data.aws_availability_zones.all.names)

  route_table_id         = element(aws_route_table.database.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat.*.id, count.index)
}


# Route Table Association
resource "aws_route_table_association" "public" {
  count          = length(data.aws_availability_zones.all.names)

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public.*.id, count.index)
}

resource "aws_route_table_association" "private" {
  count          = length(data.aws_availability_zones.all.names)

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_route_table_association" "database" {
  count          = length(data.aws_availability_zones.all.names)

  subnet_id      = element(aws_subnet.database.*.id, count.index)
  route_table_id = element(aws_route_table.database.*.id, count.index)
}
