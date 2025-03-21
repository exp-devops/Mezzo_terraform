locals {
  common_tags             = var.tags
}

resource "azurerm_container_registry" "container_registry" {
  name                = "${var.project_name}${var.project_environment}acr"
  resource_group_name = var.rg_mezzo
  location            = var.location
  sku                 = "Premium"
  public_network_access_enabled = false
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-acr"}
  )

}

resource "azurerm_private_endpoint" "acr_private_endpoint" {
  name                = "${var.project_name}-${var.project_environment}-acr-private-endpoint"
  location            = var.location
  resource_group_name = var.rg_mezzo
  subnet_id           = var.privatesubet1_id  # Replace with a private subnet
 
  private_service_connection {
    name                           = "${var.project_name}-${var.project_environment}-acr-private-connection"
    private_connection_resource_id = azurerm_container_registry.container_registry.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-acr-private-endpoint"}
  )
}

resource "azurerm_private_dns_zone" "acr_dns_zone" {
  name                = "privatelink.azurecr.io"
  resource_group_name = var.rg_mezzo
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-acr-dns-zone"}
  )
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_link" {
  name                  = "${var.project_name}-${var.project_environment}-sql-dns-link"
  resource_group_name   = var.rg_mezzo
  private_dns_zone_name = azurerm_private_dns_zone.acr_dns_zone.name
  virtual_network_id    = var.vnet_id
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-sql-dns-link"}
  )
}
