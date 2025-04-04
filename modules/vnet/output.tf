# Output Virtual Network ID
output "vnet_id" {
    value = azurerm_virtual_network.tf_vnet.id
}
# Output Public Subnet 1 ID
output "publicsubnet1_id" {
    value = azurerm_subnet.tf_public_zone1.id
}
# Output Public Subnet 2 ID
output "publicsubnet2_id" {
    value = azurerm_subnet.tf_public_zone2.id
}
# Output Private Subnet 1 ID
output "privatesubnet1_id" {
    value = azurerm_subnet.tf_private_zone1.id
}
# Output private Subnet 2 ID
output "privatesubnet2_id" {
    value = azurerm_subnet.tf_private_zone2.id
}