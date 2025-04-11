# Output Azure Key Vault ID"
output "vault_id" {
  description = "The Azure Key Vault ID"
  value       = azurerm_key_vault.tf_key_vault.id
}
# Output Azure Key Vault URI"
output "vault_uri" {
  description = "The Azure Key Vault URI"
  value       = azurerm_key_vault.tf_key_vault.vault_uri
}
# Output Azure Key Vault Name"
output "vault_name" {
  description = "The Azure Key Vault Name"
  value       = azurerm_key_vault.tf_key_vault.name
}
/*
output "keyvault_tenant_id" {
  value = azurerm_key_vault_secret.tenant_id
}
output "keyvault_subscription_id" {
  value = azurerm_key_vault_secret.subscription_id
}*/