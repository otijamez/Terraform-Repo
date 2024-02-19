
resource "azurerm_mssql_server" "sql-server" {
  name                         = "server46454"
  resource_group_name          = azurerm_resource_group.rgroup.name
  location                     = azurerm_resource_group.rgroup.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "Password123@"
}

resource "azurerm_mssql_database" "sql-server-db" {
  name           = "database46454"
  server_id      = azurerm_mssql_server.sql-server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 1
  sku_name       = "Basic"
  zone_redundant = false
  enclave_type   = "VBS"
  
  depends_on = [  
    azurerm_mssql_server.sql-server
   ]
}

resource "azurerm_mssql_firewall_rule" "sql-firewall" {
  name             = "sql-server-Firewall-Rule"
  server_id        = azurerm_mssql_server.sql-server.id
  start_ip_address = "129.205.113.176"
  end_ip_address   = "129.205.113.176"
  depends_on = [ 
    azurerm_mssql_server.sql-server
   ]
}

