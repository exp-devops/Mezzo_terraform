output "vault_id" {
  description = "The Azure Key Vault ID"
  value       = azurerm_key_vault.tf_key_vault.id
}

output "vault_uri" {
  description = "The Azure Key Vault URI"
  value       = azurerm_key_vault.tf_key_vault.vault_uri
}

output "vault_name" {
  description = "The Azure Key Vault Name"
  value       = azurerm_key_vault.tf_key_vault.name
}