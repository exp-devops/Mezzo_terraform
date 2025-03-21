locals {
  common_tags             = var.tags
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "tf_key_vault" {
  location                        = var.location
  name                            = "${var.project_name}-${var.project_environment}-keyvault"
  resource_group_name             = var.rg_mezzo
  sku_name                        = "standard"
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-keyvault"}
  )
 

  access_policy {
    object_id = data.azurerm_client_config.current.object_id
    tenant_id = data.azurerm_client_config.current.tenant_id

    secret_permissions      = ["List", "Set", "Get", "Delete", "Purge", "Recover"]
    certificate_permissions = ["Create", "Delete", "Get", "List", "Recover", "Purge"]

    key_permissions = [
      "Create",
      "Delete",
      "Get",
      "Purge",
      "Recover",
      "Update",
      "GetRotationPolicy",
      "SetRotationPolicy",
      "List"
    ]
  }

  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }
}