output "vnet_id" {
    value = azurerm_virtual_network.tf_vnet.id
}
output "publicsubnet1_id" {
    value = azurerm_subnet.tf_public_zone1.id
}
output "publicsubnet2_id" {
    value = azurerm_subnet.tf_public_zone2.id
}
output "privatesubnet1_id" {
    value = azurerm_subnet.tf_private_zone1.id
}
output "privatesubnet2_id" {
    value = azurerm_subnet.tf_private_zone2.id
}