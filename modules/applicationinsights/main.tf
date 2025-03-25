locals {
  common_tags             = var.tags
}

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = "${var.project_name}-${var.project_environment}-log-analytics-workspace"
  location            = var.location
  resource_group_name = var.rg_mezzo
  sku                 = var.workspace_sku
  retention_in_days   = var.retention_in_days
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-log-analytics-workspace"}
  )
}

resource "azurerm_application_insights" "application_insights" {
  name                = "${var.project_name}-${var.project_environment}-application-insights"
  location            = var.location
  resource_group_name = var.rg_mezzo
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.log_analytics_workspace.id
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-application-insights"}
  )
  
}