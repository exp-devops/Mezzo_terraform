output "vnet_id" {
    value = azurerm_virtual_network.tf_vnet.id
}
output "publicsubet1_id" {
    value = azurerm_subnet.tf_public_zone1.id
}
output "publicsubet2_id" {
    value = azurerm_subnet.tf_public_zone2.id
}
output "privatesubet1_id" {
    value = azurerm_subnet.tf_private_zone1.id
}
output "privatesubet2_id" {
    value = azurerm_subnet.tf_private_zone2.id
}