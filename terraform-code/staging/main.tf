
resource "azurerm_resource_group" "weight-tracker-app" {
  name     = "${var.projectPrefix}-staging"
  location = var.location
}

locals {
  instance_count = var.num
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.weight-tracker-app.location
  resource_group_name = azurerm_resource_group.weight-tracker-app.name
}

