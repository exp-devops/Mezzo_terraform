#Output the Azure Container Registry (ACR) resource ID.
output "acr_id" {
    value = azurerm_container_registry.container_registry.id
}
#Output the Azure Container Registry (ACR) resource name.
output "acr_name" {
    value = azurerm_container_registry.container_registry.name
}