# Common tags to apply to all resources
locals {
  common_tags                     = var.tags
}

# Retrieves the current Azure client configuration
data "azurerm_client_config" "current" {

}
# An Azure Key Vault for securely storing secrets, keys, and certificates
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
 
  # Configures access policies for the current user/service principal
  access_policy {                                                                                 
    object_id = data.azurerm_client_config.current.object_id
    tenant_id = data.azurerm_client_config.current.tenant_id

    secret_permissions           = ["List", "Set", "Get", "Delete", "Purge", "Recover"]           # Permissions for managing secrets
    certificate_permissions      = ["Create", "Delete", "Get", "List", "Recover", "Purge"]        # Permissions for managing certificates

    key_permissions              = [                                                              # Permissions for managing encryption keys and rotation policies
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

  network_acls {                                                                                  # Network access settings
    bypass                      = "AzureServices"
    default_action              = "Allow"
  }
}

resource "azurerm_key_vault_secret" "tenant_id" {
  name         = "${var.project_name}-${var.project_environment}-tenant-id-secret"
  value        = data.azurerm_client_config.current.tenant_id   
  key_vault_id = azurerm_key_vault.tf_key_vault.id
}

resource "azurerm_key_vault_secret" "subscription_id" {
  name         = "${var.project_name}-${var.project_environment}-subscription-id-secret"
  value        = data.azurerm_client_config.current.subscription_id   
  key_vault_id = azurerm_key_vault.tf_key_vault.id
}

resource "azurerm_key_vault_secret" "tenant_id" {
  name         = "${var.project_name}-${var.project_environment}-tenant-id-secret"
  value        = data.azurerm_client_config.current.tenant_id   
  key_vault_id = azurerm_key_vault.tf_key_vault.id
}
