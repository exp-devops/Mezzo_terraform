output "appgw_public_ip" {
    value = azurerm_public_ip.appgw_pip.ip_address
  
}
output "appgw_name" {
    value = azurerm_application_gateway.appgw.name
  
}