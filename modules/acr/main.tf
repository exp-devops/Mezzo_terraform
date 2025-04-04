# Common tags to apply to all resources
locals {
  common_tags                   = var.tags
}

 # Azure Container Registry (ACR) for storing and managing container images.
resource "azurerm_container_registry" "container_registry" { 
  name                          = "${var.project_name}${var.project_environment}projectacr"     
  resource_group_name           = var.rg_mezzo                                                 
  location                      = var.location                                                 
  sku                           = "Standard"                                                   
  public_network_access_enabled = true                                                         # Set to true to enable admin user authentication
  tags = merge(                                                                                
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-acr"}
  )
}
