resource "azurerm_subnet" "private" {
  name                 = var.subnets.private
  resource_group_name  = azurerm_resource_group.weight-tracker-app.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.4.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_private_dns_zone" "example" {
  name                = "example.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.weight-tracker-app.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "exampleVnetZone.com"
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.weight-tracker-app.name
}

resource "azurerm_postgresql_flexible_server" "db" {
  name                   = "production-db"
  resource_group_name    = azurerm_resource_group.weight-tracker-app.name
  location               = azurerm_resource_group.weight-tracker-app.location
  version                = "13"
  delegated_subnet_id    = azurerm_subnet.private.id
  private_dns_zone_id    = azurerm_private_dns_zone.example.id
  administrator_login    = var.admin
  administrator_password = var.password

  storage_mb = 32768

  sku_name   = "GP_Standard_D4s_v3"
  depends_on = [azurerm_private_dns_zone_virtual_network_link.example]

}

resource "azurerm_postgresql_flexible_server_database" "example" {
  name      = "${var.projectPrefix}-db"
  server_id = azurerm_postgresql_flexible_server.db.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

resource "azurerm_postgresql_flexible_server_configuration" "example" {
  name      = "backslash_quote"
  server_id = azurerm_postgresql_flexible_server.db.id
  value     = "off"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "example" {
  name      = "example-fw"
  server_id = azurerm_postgresql_flexible_server.PosrgreSQLFlexibleDataServer.id

  start_ip_address = "20.203.173.85"
  end_ip_address   = "20.203.173.85"
}


resource "azurerm_postgresql_flexible_server_configuration" "flexible_server_configuration" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.PosrgreSQLFlexibleDataServer.id
  value     = "off"

}
