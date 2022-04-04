resource "azurerm_public_ip" "AnsibleMasterIp" {
  name                = "AnsibleMasterIp"
  location            = azurerm_resource_group.weight-tracker-app.location
  resource_group_name = azurerm_resource_group.weight-tracker-app.name
  allocation_method   = "static"
}

resource "azurerm_network_interface" "AnsibleMaster" {
  name                = "AnsibleMaster"
  location            = azurerm_resource_group.weight-tracker-app.location
  resource_group_name = azurerm_resource_group.weight-tracker-app.name

  ip_configuration {
    name                          = "AnsibleMasterConfiguration"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.AnsibleMasterIp.id
  }
}

resource "azurerm_linux_virtual_machine" "Controller" {
  name                  = "Controller"
  location              = azurerm_resource_group.weight-tracker-app.location
  resource_group_name   = azurerm_resource_group.weight-tracker-app.name
  network_interface_ids = [azurerm_network_interface.AnsibleMaster.id]
  size                  = "Standard_B1ls"
  admin_username        = var.admin
  admin_password        = var.password
  disable_password_authentication = false

  os_disk {
    caching       = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

}
