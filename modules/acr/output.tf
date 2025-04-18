#Output the Azure Container Registry (ACR) resource ID.
output "acr_id" {
    value = azurerm_container_registry.container_registry.id
}
#Output the Azure Container Registry (ACR) resource name.
output "acr_name" {
    value = azurerm_container_registry.container_registry.name
}

output "acr_admin_username" {
  value = azurerm_container_registry.container_registry.admin_username
}

output "acr_admin_password" {
  value     = azurerm_container_registry.container_registry.admin_password
  sensitive = true
}
output "acr_url" {
  value = azurerm_container_registry.container_registry.login_server
}