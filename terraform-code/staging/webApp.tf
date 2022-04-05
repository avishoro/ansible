resource "azurerm_subnet" "public" {
  name                 = var.subnets.public
  resource_group_name  = azurerm_resource_group.weight-tracker-app.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}


#PROBE BLOCKS REQUIRED FOR THE OPERATION OF LOAD BALNCER

resource "azurerm_lb_probe" "http" {
  name                = "http-running-probe"
  loadbalancer_id     = azurerm_lb.load-balancer.id
  port                = 8080
}
resource "azurerm_lb_probe" "ssh" {
  name                = "http-ssh-probe"
  loadbalancer_id     = azurerm_lb.load-balancer.id
  port                = 22
}

# Azure Public Ip for Load Balancer

resource "azurerm_public_ip" "ip" {
  name                = "${var.projectPrefix}-ip"
  resource_group_name = azurerm_resource_group.weight-tracker-app.name
  location            = azurerm_resource_group.weight-tracker-app.location
  allocation_method   = "Static"
  sku                 = "Standard"
}



# Manages an Availability Set for Virtual Machines.

resource "azurerm_availability_set" "avset" {
  name                         = "${var.projectPrefix}-avset"
  location                     = azurerm_resource_group.weight-tracker-app.location
  resource_group_name          = azurerm_resource_group.weight-tracker-app.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

# Manages a network security group that contains a list of network security rules

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

# Associates a Network Security Group with a Subnet within a Virtual Network.

resource "azurerm_subnet_network_security_group_association" "nsg" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.webNsg.id
}

#LOAD BALANCER BLOCK

resource "azurerm_lb" "load-balancer" {
  name                = "${var.projectPrefix}-lb"
  location            = azurerm_resource_group.weight-tracker-app.location
  resource_group_name = azurerm_resource_group.weight-tracker-app.name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.ip.id
  }
}

#CREATING BACKEND POOL's FOR THE LOAD BALANCER

resource "azurerm_lb_backend_address_pool" "pool" {
  loadbalancer_id = azurerm_lb.load-balancer.id
  name            = "BackEndAddressPool"
}

# Configuring the load balncer inbound rules to allow outside access to the load balancer

resource "azurerm_lb_rule" "http" {
  loadbalancer_id                = azurerm_lb.load-balancer.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.pool.id]
  probe_id                       = azurerm_lb_probe.http.id
}

resource "azurerm_lb_rule" "ssh" {
  loadbalancer_id                = azurerm_lb.load-balancer.id
  name                           = "sshRule"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.pool.id]
  probe_id                       = azurerm_lb_probe.ssh.id
}

# Manages the association between a Network Interface and a Load Balancer's Backend Address Pool.

resource "azurerm_network_interface_backend_address_pool_association" "pool_association" {
  count                   = var.num
  backend_address_pool_id = azurerm_lb_backend_address_pool.pool.id
  ip_configuration_name   = "primary"
  network_interface_id    = module.vms[count.index].nic_id
}


#calling to a module to build vms for running the app

resource "azurerm_resource_group" "VMs" {
  name     = "${var.prefix}-VMs-resources"
  location = var.location
}

module "vms" {
  source         = "./modules/vm"
  count          = var.num
  name           = "${var.prefix}-vm-${count.index}"
  resource_group = azurerm_resource_group.VMs
  webAppMachines_username = var.admin
  webAppMachines_password = var.password
  subnet_id      = azurerm_subnet.public.id
  depends_on     = [azurerm_lb.load-balancer]
}
