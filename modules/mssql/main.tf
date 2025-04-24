# Define local values for common tags to maintain consistency across resources.
locals {
  common_tags = var.tags
}

# Generate a random password for the SQL administrator user.
resource "random_password" "sql_password" {
  length           = 32
  special          = true
  override_special = "!@"
}

# Create an Azure SQL Server with an administrator login and a randomly generated password.
resource "azurerm_mssql_server" "sql_server" {
  name                         = "${var.project_name}-${var.project_environment}-sql-server"
  location                     = var.location
  resource_group_name          = var.rg_mezzo
  version                      = "12.0"
  administrator_login          = "sqladminuser"
  administrator_login_password = random_password.sql_password.result
  public_network_access_enabled = true

  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-sql-server"}
  )
}

# Create an Azure SQL Database with a specified SKU and size.
resource "azurerm_mssql_database" "sql_database" {
  name           = "${var.project_name}-${var.project_environment}-sql-database"
  server_id      = azurerm_mssql_server.sql_server.id
  sku_name       = var.sql_sku_name  
  max_size_gb    = var.max_size_gb 
  zone_redundant = false

  # Enable Geo-Redundant Backup (Long-term Retention)
  storage_account_type = "Geo"  

  tags = merge(
    local.common_tags, {"Name"="${var.project_name}-${var.project_environment}-sql-database"}
  )
}

# Store the SQL administrator password in Azure Key Vault as a secret.

resource "azurerm_key_vault_secret" "sql_password_secret" {
  depends_on   = [azurerm_mssql_server.sql_server]
  name         = "${var.project_name}-${var.project_environment}-mssql-password-secret"
  value        = random_password.sql_password.result
  key_vault_id = var.vault_id
}

resource "azurerm_key_vault_secret" "sql_connection_string" {
  depends_on   = [azurerm_mssql_server.sql_server]
  name         = "ConnectionStrings--DefaultConnection"
  value        = "Data Source= ${azurerm_mssql_server.sql_server.name}.privatelink.database.windows.net;Initial Catalog=${azurerm_mssql_database.sql_database.name} ;Integrated Security =False; UID=${azurerm_mssql_server.sql_server.administrator_login}; Password=${azurerm_mssql_server.sql_server.administrator_login_password};MultipleActiveResultSets=true;"
  key_vault_id = var.vault_id
}
# Create a private endpoint for the Azure SQL Server to enable private access.
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

# Create a Private DNS Zone for the SQL Server to resolve its private IP.
resource "azurerm_private_dns_zone" "sql_dns_zone" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.rg_mezzo
}

# Link the Private DNS Zone to the Virtual Network for name resolution.
resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_link" {
  name                  = "${var.project_name}-${var.project_environment}-sql-dns-link"
  resource_group_name   = var.rg_mezzo
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns_zone.name
  virtual_network_id    = var.vnet_id
}

# Create a firewall rule to allow Azure services to access the SQL Server.
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  depends_on       = [azurerm_mssql_server.sql_server]
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
resource "azurerm_private_dns_a_record" "sql_private_dns_a_record" {
  name                = azurerm_mssql_server.sql_server.name # example: mydbserver
  zone_name           = azurerm_private_dns_zone.sql_dns_zone.name
  resource_group_name = var.rg_mezzo
  ttl                 = 300
  records             = [azurerm_private_endpoint.sql_private_endpoint.private_service_connection[0].private_ip_address]

  tags = local.common_tags
}
