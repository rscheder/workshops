provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}
resource "azurerm_resource_group" "rg01" {
  name      = "yarg001"
  location  = var.location
  tags      = {
    Name          = "yet another resource group"
    Environment   = "Development"
  }
}
resource "azurerm_virtual_network" "vnet01" {
  name                = "wsvnet01"
  resource_group_name = azurerm_resource_group.rg01.name
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.rg01.location
  tags                = {
    Name              = "Ralf Schederecker"
    Environment       = "Development"
  }
}

resource "azurerm_subnet" "vnetsub01" {
  name                 = "wsvnetsub01"
  resource_group_name  = azurerm_resource_group.rg01.name
  virtual_network_name = azurerm_virtual_network.vnet01.name
  address_prefix       = "10.10.1.0/24"
}

resource "azurerm_subnet" "vnetsub02" {
  name                 = "wsvnetsub02"
  resource_group_name  = azurerm_resource_group.rg01.name
  virtual_network_name = azurerm_virtual_network.vnet01.name
  address_prefix       = "10.10.2.0/24"
}

resource "azurerm_subnet" "vnetsubgw" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg01.name
  virtual_network_name = azurerm_virtual_network.vnet01.name
  address_prefix       = "10.10.255.0/27"
}

# enable global network peering between two virtual networks

resource "azurerm_virtual_network_peering" "vnetpeer01" {
  name                      = "peer1to2"
  resource_group_name       =  azurerm_resource_group.rg01.name
  virtual_network_name      =  azurerm_virtual_network.vnet01.name
  remote_virtual_network_id =  azurerm_virtual_network.partnervnet01.id
  allow_virtual_network_access  = true
  allow_forwarded_traffic       = true
  allow_gateway_transit         = false
}

resource "azurerm_public_ip" "pip01" {
  name                = "wspip01"
  resource_group_name = azurerm_resource_group.rg01.name
  location            = azurerm_resource_group.rg01.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "nsg01" {
  name                = "wsnsg01"
  resource_group_name = azurerm_resource_group.rg01.name
  location            = azurerm_resource_group.rg01.location
}

data "azurerm_public_ip" "pip01" {
  name                = azurerm_public_ip.pip01.name
  resource_group_name = azurerm_resource_group.rg01.name
}

resource "azurerm_network_security_rule" "rdp" {
  name                        = "rdp"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = data.azurerm_public_ip.pip01.ip_address
  destination_port_range      = "3389"
  source_address_prefix       = data.azurerm_public_ip.pip01.ip_address
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.rg01.name
  network_security_group_name = azurerm_network_security_group.nsg01.name
}

resource "azurerm_network_interface" "nic01" {
  name                      = "wsnic01"
  resource_group_name       = azurerm_resource_group.rg01.name
  location                  = azurerm_resource_group.rg01.location
  network_security_group_id = azurerm_network_security_group.nsg01.id
  ip_configuration {
    name                          = "wsipc01"
    subnet_id                     = azurerm_subnet.vnetsub01.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip01.id
  }
}