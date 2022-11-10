locals {
  pn_name         = "ansible-pn"
  bastion_address = "${scaleway_vpc_public_gateway_ip.gw_ip.address}:${scaleway_vpc_public_gateway.gw.bastion_port}"
}
variable "private_network_cidr" {
  type = string
}
variable "dhcp_pool_high" {
  type = string
}

# Private Networks 1
resource "scaleway_vpc_private_network" "pn1" {
  name = local.pn_name
}

resource "scaleway_vpc_public_gateway_dhcp" "dhcp_pn1" {
  subnet             = var.private_network_cidr
  pool_high          = var.dhcp_pool_high
  push_default_route = true
  dns_local_name     = local.pn_name # if you don't put the dns_local_name here it will be by default equal to priv and wont be aligned with bastion connection
}
resource "scaleway_vpc_gateway_network" "vcp_gtw_association1" {
  gateway_id         = scaleway_vpc_public_gateway.gw.id
  private_network_id = scaleway_vpc_private_network.pn1.id
  dhcp_id            = scaleway_vpc_public_gateway_dhcp.dhcp_pn1.id
  enable_dhcp        = true
  cleanup_dhcp       = false
  depends_on         = [scaleway_vpc_private_network.pn1]

}

# Public Gateway 
resource "scaleway_vpc_public_gateway_ip" "gw_ip" {}

resource "scaleway_vpc_public_gateway" "gw" {
  name            = "public-gateway-svd"
  type            = "VPC-GW-S"
  ip_id           = scaleway_vpc_public_gateway_ip.gw_ip.id
  bastion_enabled = true

}