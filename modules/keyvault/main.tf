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
  name                            = "${var.project_name}-${var.project_environment}-vault"     
  resource_group_name             = var.rg_mezzo                                                  
  sku_name                        = "standard"                                                    
  tenant_id                       = data.azurerm_client_config.current.tenant_id                  
  enabled_for_disk_encryption     = true                                                          
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  
  /*enable_rbac_authorization       = true */
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-vault"}         
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
  access_policy {
    tenant_id = var.aks_tenantid
    object_id = var.aks_objectid

  secret_permissions           = ["List", "Set", "Get", "Delete", "Purge", "Recover"]           # Permissions for managing secrets
    certificate_permissions      = ["Create","Delete", "Get", "List", "Recover", "Purge"]        # Permissions for managing certificates

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
  access_policy {
    tenant_id = var.aks_tenantid
    object_id = var.aks_objectid

  secret_permissions           = ["List", "Set", "Get", "Delete", "Purge", "Recover"]           # Permissions for managing secrets
    certificate_permissions      = ["Create","Delete", "Get", "List", "Recover", "Purge"]        # Permissions for managing certificates

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
access_policy {
    tenant_id = var.aks_tenantid
    object_id = var.aks_objectid

  secret_permissions           = ["List", "Set", "Get", "Delete", "Purge", "Recover"]           # Permissions for managing secrets
    certificate_permissions      = ["Create","Delete", "Get", "List", "Recover", "Purge"]        # Permissions for managing certificates

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
  access_policy {
    tenant_id = var.aks_tenantid
    object_id = var.vmss_uami

  secret_permissions           = ["List", "Set", "Get", "Delete", "Purge", "Recover"]           # Permissions for managing secrets
    certificate_permissions      = ["Create","Delete", "Get", "List", "Recover", "Purge"]        # Permissions for managing certificates

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



