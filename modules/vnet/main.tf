# Common tags to apply to all resources
locals {
  common_tags             = var.tags
}
# virtual Network
resource "azurerm_virtual_network" "tf_vnet" {
  name                = "${var.project_name}-${var.project_environment}-vnet"
  location            = var.location
  resource_group_name = var.rg_mezzo
  address_space       = var.vnet_address_space
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-vnet"}
  )
}
# Public Subnet 1
resource "azurerm_subnet" "tf_public_zone1" {
  name                 = "${var.project_name}-${var.project_environment}-public-subnet-1"
  resource_group_name  = var.rg_mezzo
  virtual_network_name = azurerm_virtual_network.tf_vnet.name
  address_prefixes     = var.subnet_cidr["SUBNET_01"]
  
}
# Public Subnet 2
resource "azurerm_subnet" "tf_public_zone2" {
  name                 = "${var.project_name}-${var.project_environment}-public-subnet-2"
  resource_group_name  = var.rg_mezzo
  virtual_network_name = azurerm_virtual_network.tf_vnet.name
  address_prefixes     = var.subnet_cidr["SUBNET_02"]
}
# Private Subnet 1
resource "azurerm_subnet" "tf_private_zone1" {
  name                 = "${var.project_name}-${var.project_environment}-private-subnet-1"
  resource_group_name  = var.rg_mezzo
  virtual_network_name = azurerm_virtual_network.tf_vnet.name
  address_prefixes     = var.subnet_cidr["SUBNET_03"]
}
# Private Subnet 2
resource "azurerm_subnet" "tf_private_zone2" {
  name                 = "${var.project_name}-${var.project_environment}-private-subnet-2"
  resource_group_name  = var.rg_mezzo
  virtual_network_name = azurerm_virtual_network.tf_vnet.name
  address_prefixes     = var.subnet_cidr["SUBNET_04"]
}



