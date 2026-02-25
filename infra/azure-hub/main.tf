resource "azurerm_resource_group" "hub" {
  name     = "rg-hybrid-hub"
  location = var.location
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hybrid-hub"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = [var.hub_vnet_cidr]
}

resource "azurerm_subnet" "gateway" {
  name                 = "snet-gateway"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.gateway_subnet_cidr]
}

resource "azurerm_public_ip" "gateway" {
  name                = "pip-wireguard"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "gateway" {
  name                = "nsg-wireguard"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  security_rule {
    name                       = "Allow-WireGuard"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "51820"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "gateway" {
  name                = "nic-wireguard"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.gateway.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.gateway.id
  }
}

resource "azurerm_network_interface_security_group_association" "gateway" {
  network_interface_id      = azurerm_network_interface.gateway.id
  network_security_group_id = azurerm_network_security_group.gateway.id
}

resource "azurerm_linux_virtual_machine" "gateway" {
  name                = "vm-wireguard-gateway"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  size                = var.vm_size

  admin_username = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.gateway.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("/home/chirag/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
