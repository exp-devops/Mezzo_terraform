# Output resources Group
output "rg_mezzo" {
    value = azurerm_resource_group.tf_resource_group_mezzo.name
}
output "rg_mezzo_id" {
    value = azurerm_resource_group.tf_resource_group_mezzo.id
}