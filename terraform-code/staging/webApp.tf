resource "azurerm_subnet" "public" {
  name                 = var.subnets.public
  resource_group_name  = azurerm_resource_group.weight-tracker-app.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}



resource "azurerm_lb_probe" "example" {
  name                = "http-running-probe"
  loadbalancer_id     = azurerm_lb.example.id
  port                = 8080
}
resource "azurerm_lb_probe" "ssh" {
  name                = "http-ssh-probe"
  loadbalancer_id     = azurerm_lb.example.id
  port                = 22
}

resource "azurerm_public_ip" "ip" {
  name                = "${var.projectPrefix}-ip"
  resource_group_name = azurerm_resource_group.weight-tracker-app.name
  location            = azurerm_resource_group.weight-tracker-app.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "webApp" {
  count               = local.instance_count
  name                = "${var.projectPrefix}-nic${count.index}"
  resource_group_name = azurerm_resource_group.weight-tracker-app.name
  location            = azurerm_resource_group.weight-tracker-app.location

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
  }
}



resource "azurerm_availability_set" "avset" {
  name                         = "${var.projectPrefix}-avset"
  location                     = azurerm_resource_group.weight-tracker-app.location
  resource_group_name          = azurerm_resource_group.weight-tracker-app.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_network_security_group" "webNsg" {
  name                = "webNsg"
  location            = azurerm_resource_group.weight-tracker-app.location
  resource_group_name = azurerm_resource_group.weight-tracker-app.name
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "port8080"
    priority                   = 110
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "8080"
    destination_address_prefix = "*"
  }
   security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "port22"
    priority                   = 120
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = var.myIP
    destination_port_range     = "22"
    destination_address_prefix = "*"
  }
}



resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.webNsg.id
}



resource "azurerm_lb" "example" {
  name                = "${var.projectPrefix}-lb"
  location            = azurerm_resource_group.weight-tracker-app.location
  resource_group_name = azurerm_resource_group.weight-tracker-app.name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "example" {
  loadbalancer_id = azurerm_lb.example.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_rule" "example" {
  loadbalancer_id                = azurerm_lb.example.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.example.id]
  probe_id                       = azurerm_lb_probe.example.id
}

resource "azurerm_lb_rule" "ssh" {
  loadbalancer_id                = azurerm_lb.example.id
  name                           = "sshRule"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.example.id]
  probe_id                       = azurerm_lb_probe.ssh.id
}

resource "azurerm_network_interface_backend_address_pool_association" "example" {
  count                   = local.instance_count
  backend_address_pool_id = azurerm_lb_backend_address_pool.example.id
  ip_configuration_name   = "primary"
  network_interface_id    = element(azurerm_network_interface.webApp.*.id, count.index)
}

resource "azurerm_linux_virtual_machine" "webApp" {
  count                           = local.instance_count
  name                            = "${var.projectPrefix}-vm${count.index}"
  resource_group_name             = azurerm_resource_group.weight-tracker-app.name
  location                        = azurerm_resource_group.weight-tracker-app.location
  size                            = "Standard_b1ls"
  admin_username                  = var.admin
  admin_password                  = var.password
  availability_set_id             = azurerm_availability_set.avset.id
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.webApp[count.index].id,
  ]

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

