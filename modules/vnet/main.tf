locals {
  common_tags             = var.tags
}
resource "azurerm_virtual_network" "tf_vnet" {
  name                = "${var.project_name}-${var.project_environment}-vnet"
  location            = var.location
  resource_group_name = var.rg_mezzo
  address_space       = var.vnet_address_space
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-vnet"}
  )
}
resource "azurerm_subnet" "tf_public_zone1" {
  name                 = "${var.project_name}-${var.project_environment}-public-subnet-1"
  resource_group_name  = var.rg_mezzo
  virtual_network_name = azurerm_virtual_network.tf_vnet.name
  address_prefixes     = var.subnet_cidr["SUBNET_01"]
  
}

resource "azurerm_subnet" "tf_public_zone2" {
  name                 = "${var.project_name}-${var.project_environment}-public-subnet-2"
  resource_group_name  = var.rg_mezzo
  virtual_network_name = azurerm_virtual_network.tf_vnet.name
  address_prefixes     = var.subnet_cidr["SUBNET_02"]
}

resource "azurerm_subnet" "tf_private_zone1" {
  name                 = "${var.project_name}-${var.project_environment}-private-subnet-1"
  resource_group_name  = var.rg_mezzo
  virtual_network_name = azurerm_virtual_network.tf_vnet.name
  address_prefixes     = var.subnet_cidr["SUBNET_03"]
}

resource "azurerm_subnet" "tf_private_zone2" {
  name                 = "${var.project_name}-${var.project_environment}-private-subnet-2"
  resource_group_name  = var.rg_mezzo
  virtual_network_name = azurerm_virtual_network.tf_vnet.name
  address_prefixes     = var.subnet_cidr["SUBNET_04"]
}
resource "azurerm_public_ip" "tf_nat_ip_1" {
  name                = "${var.project_name}-${var.project_environment}-nat-ip-1"
  location            = var.location
  resource_group_name = var.rg_mezzo
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
   tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-nat-ip-1"}
  )
}

resource "azurerm_nat_gateway" "tf_azurerm_nat_gateway1" {
  name                = "${var.project_name}-${var.project_environment}-nat-gateway-1"
  location            = var.location
  resource_group_name = var.rg_mezzo
  sku_name            = "Standard"
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-nat-gateway-1"}
  )
 
}
resource "azurerm_public_ip" "tf_nat_ip_2" {
  name                = "${var.project_name}-${var.project_environment}-nat-ip-2"
  location            = var.location
  resource_group_name = var.rg_mezzo
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["2"]
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-nat-ip-2"}
  )
}

resource "azurerm_nat_gateway" "tf_azurerm_nat_gateway2" {
  name                = "${var.project_name}-${var.project_environment}-nat-gateway-2"
  location            = var.location
  resource_group_name = var.rg_mezzo
  sku_name            = "Standard"
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-nat-gateway-2"}
  )
}

# Associate Public IPs with NAT Gateways
resource "azurerm_nat_gateway_public_ip_association" "tf_natgw_ip_assoc1" {
  nat_gateway_id       = azurerm_nat_gateway.tf_azurerm_nat_gateway1.id
  public_ip_address_id = azurerm_public_ip.tf_nat_ip_1.id
}
 
resource "azurerm_nat_gateway_public_ip_association" "tf_natgw_ip_assoc2" {
  nat_gateway_id       = azurerm_nat_gateway.tf_azurerm_nat_gateway2.id
  public_ip_address_id = azurerm_public_ip.tf_nat_ip_2.id
}
 
# Associate NAT Gateways with Private Subnets

resource "azurerm_subnet_nat_gateway_association" "private_subnet1_natgw" {
  subnet_id      = azurerm_subnet.tf_private_zone1.id
  nat_gateway_id = azurerm_nat_gateway.tf_azurerm_nat_gateway1.id

}
 
resource "azurerm_subnet_nat_gateway_association" "private_subnet2_natgw" {
  subnet_id      = azurerm_subnet.tf_private_zone2.id
  nat_gateway_id = azurerm_nat_gateway.tf_azurerm_nat_gateway2.id
}

