# Output resources Group name
output "rg_mezzo" {
    value = azurerm_resource_group.tf_resource_group_mezzo.name
}
# Output resources Group ID
output "rg_mezzo_id" {
    value = azurerm_resource_group.tf_resource_group_mezzo.id
}