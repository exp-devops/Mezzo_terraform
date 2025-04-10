# Common tags to apply to all resources
locals {
  common_tags             = var.tags
}
# Creates an Azure Resource Group for managing related resources
resource "azurerm_resource_group" "tf_resource_group_mezzo" {
  name                    = "${var.project_name}-${var.project_environment}-resource-group"                    
  location                = var.location                                                                       
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-resource-group"}                
  )
}