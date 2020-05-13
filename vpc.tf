terraform {
  backend "s3" {
    bucket         = "robertgillsg-terraform-remote-state-storage-s3"
    key            = "global/s3/terraform.tfstate"
    region         = "ap-southeast-1"

    dynamodb_table = "terraform-state-lock-dynamo"
    encrypt        = true
  }
}

## AWS Availability Zones
data "aws_availability_zones" "all" {
  state = "available"
}

## VPC
resource "aws_vpc" "vpc" {
  cidr_block                       = var.vpc_cidr["cidr_block"]
  instance_tenancy                 = var.tenancy
  enable_dns_support               = var.enable_dns_support
  enable_dns_hostnames             = var.enable_dns_hostnames
  assign_generated_ipv6_cidr_block = var.enable_ipv6

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    {
      "name" = format("%s", var.vpc_name)
    },
    var.default_tags
  )
}

## Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    {
      "Name" = format("%s", var.igw_tag)
    },
    var.default_tags
  )
}


resource "aws_subnet" "public" {
  count = length(data.aws_availability_zones.all.names)

  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(data.aws_availability_zones.all.names, count.index)

  cidr_block              = element(var.subnet_cidrs_public, count.index)
  map_public_ip_on_launch = true
/**
  ipv6_cidr_block                 = "${var.use_ipv6 == 0 ? "" : cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, var.vpc["newbits"], count.index + 1)}"
  assign_ipv6_address_on_creation = "${var.use_ipv6}"
**/
}

resource "aws_subnet" "private" {
  count = length(data.aws_availability_zones.all.names)

  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(data.aws_availability_zones.all.names, count.index)

  cidr_block              = element(var.subnet_cidrs_private, count.index)
  map_public_ip_on_launch = false
/**
  ipv6_cidr_block                 = "${var.use_ipv6 == 0 ? "" : cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, var.vpc["newbits"], count.index + 100)}"
  assign_ipv6_address_on_creation = "${var.use_ipv6}"
**/
}

# NAT Gateways
resource "aws_eip" "nat_gw_eip" {
  count = length(data.aws_availability_zones.all.names)

  vpc = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "nat" {
  count = length(data.aws_availability_zones.all.names)

  allocation_id = element(aws_eip.nat_gw_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
//  private_ip    = lookup(var.nat_gateway_ips, count.index)

  depends_on    = [aws_internet_gateway.igw]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "gw NAT"
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Public Subnet Route Table"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}


resource "aws_route_table" "private" {
  count = length(data.aws_availability_zones.all.names)

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Private Subnet Route Table"
  }
}

resource "aws_route" "private" {
  count = length(data.aws_availability_zones.all.names)

  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat.*.id, count.index)
}


# Route Table Association
resource "aws_route_table_association" "public" {
  count = length(data.aws_availability_zones.all.names)

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public.*.id, count.index)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table_association" "private" {
  count = length(data.aws_availability_zones.all.names)

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)

  lifecycle {
    create_before_destroy = true
  }
}
