locals {
  common_tags             = var.tags
}
# Azure Static Web App
resource "azurerm_static_site" "tf_admin_webapp" {
  name                = "${var.project_name}-${var.project_environment}-admin-static-web-app"
  resource_group_name = var.rg_mezzo
  location            = var.location
  sku_tier            = var.static_web_app_sku_tier
  sku_size            = "Standard"

  identity {
    type = "SystemAssigned"
  }

 /* # Azure DevOps Repository Integration
  azure_devops_repository {
    repo_url        = "https://dev.azure.com/MezzoOrg/CNB/_git/CoreService"
    branch          = "main"
    app_location    = "/"
    output_location = "build"
    api_location    = ""  # No API defined
    build_preset    = "custom"
  }*/
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-admin-static-web-app"}
  )
}

# Azure Static Web App
resource "azurerm_static_site" "tf_borrow_webapp" {
  name                = "${var.project_name}-${var.project_environment}-borrow-static-web-app"
  resource_group_name = var.rg_mezzo
  location            = var.location
  sku_tier            = var.static_web_app_sku_tier
  sku_size            = "Standard"

  identity {
    type = "SystemAssigned"
  }/*

  # Azure DevOps Repository Integration
  azure_devops_repository {
    repo_url        = "https://dev.azure.com/MezzoOrg/CNB/_git/CoreService"
    branch          = "main"
    app_location    = "/"
    output_location = "build"
    api_location    = ""  # No API defined
    build_preset    = var.build_preset
  }*/

  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-borrow-static-web-app"}
  )
}

