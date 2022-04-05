
resource "azurerm_linux_virtual_machine" "webApp" {
  name                            = "${var.projectPrefix}-vm${count.index}"
  resource_group_name             = azurerm_resource_group.weight-tracker-app.name
  location                        = azurerm_resource_group.weight-tracker-app.location
  size                            = "Standard_b1ls"
  admin_username                  = var.admin
  admin_password                  = var.password
  availability_set_id             = azurerm_availability_set.avset.id
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.webApp.id]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}

resource "azurerm_network_interface" "webApp" {
  name                = "${var.name}-nic"
  location            = azurerm_resource_group.weight-tracker-app.location
  resource_group_name = azurerm_resource_group.weight-tracker-app.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
  }
}
