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

  cidr_block                       = var.vpc_cidr["cidr_block"]
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

# Internet Gateway
resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    {
      "Name" = "${var.env_name}-internet-gateway"
    },
    var.default_tags
  )
}

resource "aws_egress_only_internet_gateway" "igw" {

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    {
      "Name" = "${var.env_name}-egress-internet-gateway"
    },
    var.default_tags
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  count             = length(data.aws_availability_zones.all.names)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(data.aws_availability_zones.all.names, count.index)

//  cidr_block        = element(var.subnet_cidrs_public, count.index)
  cidr_block        = cidrsubnet(var.vpc_cidr["cidr_block"], var.vpc_cidr["newbits"], var.vpc_cidr["netnum"] * count.index + 0)

  map_public_ip_on_launch = true
/**
  ipv6_cidr_block                 = "${var.use_ipv6 == 0 ? "" : cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, var.vpc["newbits"], count.index + 1)}"
  assign_ipv6_address_on_creation = "${var.use_ipv6}"
**/
  tags = merge(
    {
      "Name" = "${var.env_name}-public-subnet-az${count.index + 1}"
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
  cidr_block        = cidrsubnet(var.vpc_cidr["cidr_block"], var.vpc_cidr["newbits"], var.vpc_cidr["netnum"] * count.index + 3)

  map_public_ip_on_launch = false
/**
  ipv6_cidr_block                 = "${var.use_ipv6 == 0 ? "" : cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, var.vpc["newbits"], count.index + 100)}"
  assign_ipv6_address_on_creation = "${var.use_ipv6}"
**/

tags = merge(
    {
      "Name" = "${var.env_name}-private-subnet-az${count.index + 1}"
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
  cidr_block        = cidrsubnet(var.vpc_cidr["cidr_block"], var.vpc_cidr["newbits"], var.vpc_cidr["netnum"] * count.index + 6)

  map_public_ip_on_launch = false
/**
  ipv6_cidr_block                 = "${var.use_ipv6 == 0 ? "" : cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, var.vpc["newbits"], count.index + 100)}"
  assign_ipv6_address_on_creation = "${var.use_ipv6}"
**/

tags = merge(
    {
      "Name" = "${var.env_name}-database-subnet-az${count.index + 1}"
    },
    var.default_tags
  )
}

# NAT Gateways
resource "aws_eip" "nat" {
  count      = length(data.aws_availability_zones.all.names)

  vpc        = true

  tags = merge(
      {
        "Name" = format("%s-nat-gateway-az%d", var.env_name, count.index + 1)
      },
      var.default_tags
    )
}

resource "aws_nat_gateway" "nat" {
  count         = length(data.aws_availability_zones.all.names)

  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  depends_on    = [aws_internet_gateway.igw]

  tags = merge(
      {
        "Name" = format("%s-nat-gateway-az%d", var.env_name, count.index + 1)
      },
      var.default_tags
    )
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
      {
        "Name" = "${var.env_name}-public-route"
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

  tags = merge(
      {
        "Name" = format("%s-private-route-az%d", var.env_name, count.index + 1)
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

  tags = merge(
      {
        "Name" = format("%s-database-route-az%d", var.env_name, count.index + 1)
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
