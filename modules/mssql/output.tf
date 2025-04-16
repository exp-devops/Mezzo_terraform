output "sql_private_endpoint" {
    value = azurerm_private_dns_zone.sql_dns_zone.name 
}
output "sql_username" {
    value = azurerm_mssql_server.sql_server.administrator_login
  
}
output "sql_password" {
    value = azurerm_mssql_server.sql_server.administrator_login_password
  
}
output "sql_db_name" {
    value = azurerm_mssql_database.sql_database.name
  
}