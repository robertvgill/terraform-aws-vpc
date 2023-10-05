# VPN Gateway
resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    {
      "Name" = "${var.env_name}-vgw"
    },
    var.default_tags
    )
}

# Customer Gateway
resource "aws_customer_gateway" "cgw1" {
  bgp_asn    = var.bgp_asn1
  ip_address = var.vpn_ip1
  type       = "ipsec.1"

  tags = merge(
    {
      "Name" = var.vpn_cgw1
    },
    var.default_tags
    )
}

resource "aws_customer_gateway" "cgw2" {
  bgp_asn    = var.bgp_asn2
  ip_address = var.vpn_ip2
  type       = "ipsec.1"

  tags = merge(
    {
      "Name" = var.vpn_cgw2
    },
    var.default_tags
    )
}

resource "aws_vpn_connection" "cgw1" {
  vpn_gateway_id      = aws_vpn_gateway.vpn_gateway.id
  customer_gateway_id = aws_customer_gateway.cgw1.id
  type                = "ipsec.1"
  static_routes_only  = false

  tags = merge(
    {
      "Name" = var.vpn_cgw1
    },
    var.default_tags
    )
}

resource "aws_vpn_connection" "cgw2" {
  vpn_gateway_id      = aws_vpn_gateway.vpn_gateway.id
  customer_gateway_id = aws_customer_gateway.cgw2.id
  type                = "ipsec.1"
  static_routes_only  = false

  tags = merge(
    {
      "Name" = var.vpn_cgw2
    },
    var.default_tags
    )
}
