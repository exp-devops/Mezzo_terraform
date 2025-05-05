# Common tags to apply to all resources
locals {
  common_tags             = var.tags
}
# Azure Static Web App-Admin
resource "azurerm_static_web_app" "tf_admin_webapp" {
  name                    = "${var.project_name}-${var.project_environment}-admin-static-web-app"        
  resource_group_name     = var.rg_mezzo                                                                 
  location                = var.location                                                                 
  sku_tier                = var.staticwebapp_sku_tier                                                  
  sku_size                = "Standard"                                                                   

  identity {
    type = "SystemAssigned"                                                                              # Use system-assigned managed identity for authentication
  }
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-admin-static-web-app"}   
  )
}

# Azure Static Web App-Borrower
resource "azurerm_static_web_app" "tf_borrower_webapp" {
  name                    = "${var.project_name}-${var.project_environment}-borrower-static-web-app"      
  resource_group_name     = var.rg_mezzo                                                                  
  location                = var.location                                                                  
  sku_tier                = var.staticwebapp_sku_tier                                                   
  sku_size                = "Standard"                                                                   

  identity {
    type                  = "SystemAssigned"                                                              # Use system-assigned managed identity for authentication
  }
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-borrower-static-web-app"}  
  )
}



