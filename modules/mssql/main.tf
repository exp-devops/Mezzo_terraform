locals {
  common_tags             = var.tags
}

resource "random_password" "sql_password" {
  length           = 32
  special          = true
  override_special = "!@"
}


resource "azurerm_mssql_server" "sql_server" {
  name                = "${var.project_name}-${var.project_environment}-sql-server"
  location            = var.location
  resource_group_name = var.rg_mezzo
  version                      = "12.0"
  administrator_login          = "sqladminuser"
  administrator_login_password = random_password.sql_password.result
  
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-sql-server"}
  )
}

resource "azurerm_mssql_database" "sql_database" {
  name           = "${var.project_name}-${var.project_environment}-sql-database"
  server_id      = azurerm_mssql_server.sql_server.id
  sku_name       = var.sql_sku_name # Example: "GP_S_Gen5_2"
  max_size_gb    = var.max_size_gb 
  zone_redundant = false
  #Enable Geo-Redundant Backup (Long-term Retention)
  storage_account_type      = "Geo"  # Options: LRS, GRS, Geo

   tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-sql-database"}
  )
}

resource "azurerm_key_vault_secret" "sql_password_secret" {
  depends_on   = [azurerm_mssql_server.sql_server]
  name         = "${var.project_name}-${var.project_environment}-sql-password-secret"
  value        = random_password.sql_password.result
  key_vault_id = var.vault_id
}

resource "azurerm_private_endpoint" "sql_private_endpoint" {
  name                = "${var.project_name}-${var.project_environment}-sql-private-endpoint"
  location            = var.location
  resource_group_name = var.rg_mezzo
 
  subnet_id           = var.privatesubnet1_id

  private_service_connection {
    name                           = "${var.project_name}-${var.project_environment}-sql-priv-connection"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }
  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-sql-private-endpoint"}
  )
 
}
resource "azurerm_private_dns_zone" "sql_dns_zone" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.rg_mezzo
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_link" {
  name                  = "${var.project_name}-${var.project_environment}-sql-dns-link"
  resource_group_name   = var.rg_mezzo
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns_zone.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  depends_on       = [azurerm_mssql_server.sql_server]
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
#Configure SQL Server Backup Policy (Long-Term Retention)
/*resource "azurerm_mssql_database_long_term_retention_policy" "example" {
  database_id            = azurerm_mssql_database.sql_database.id
  weekly_retention       = "P4W"   # Keep weekly backups for 4 weeks
  monthly_retention      = "P12M"  # Keep monthly backups for 12 months
  yearly_retention       = "P5Y"   # Keep yearly backups for 5 years
  week_of_year           = 1       # The week number for yearly retention
  
}*/
