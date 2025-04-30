# Output SQL Private Endpoint
output "sql_private_endpoint" {
    value = azurerm_private_dns_zone.sql_dns_zone.name 
}
# Output SQL username
output "sql_username" {
    value = azurerm_mssql_server.sql_server.administrator_login
  
}
# Output SQL password
output "sql_password" {
    value = azurerm_mssql_server.sql_server.administrator_login_password
  
}
# Output SQL DB name
output "sql_db_name" {
    value = azurerm_mssql_database.sql_database.name
  
}
# Output SQL server name.
output "sql-server-name" {
    value = azurerm_mssql_server.sql_server.name
  
}