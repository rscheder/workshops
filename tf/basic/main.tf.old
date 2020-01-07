provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}
resource "azurerm_resource_group" "rg01" {
  name     = "dpdwsrg001"
  location = var.location
}
resource "azurerm_virtual_network" "vnet01" {
  name                = "dpdwsvnet01"
  resource_group_name = azurerm_resource_group.rg01.name
  address_space       = ["10.11.0.0/16"]
  location            = azurerm_resource_group.rg01.location
}

resource "azurerm_subnet" "vnetsub01" {
  name                 = "dpdwsvnetsub01"
  resource_group_name  = azurerm_resource_group.rg01.name
  virtual_network_name = azurerm_virtual_network.vnet01.name
  address_prefix       = "10.11.0.0/24"
}

resource "azurerm_subnet" "vnetsub02" {
  name                 = "dpdwsvnetsub02"
  resource_group_name  = azurerm_resource_group.rg01.name
  virtual_network_name = azurerm_virtual_network.vnet01.name
  address_prefix       = "10.11.15.0/24"
}

resource "azurerm_subnet" "vnetsubgw" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg01.name
  virtual_network_name = azurerm_virtual_network.vnet01.name
  address_prefix       = "10.11.255.0/27"
}

resource "azurerm_public_ip" "pip01" {
  name                = "dpdwspip01"
  resource_group_name = azurerm_resource_group.rg01.name
  location            = azurerm_resource_group.rg01.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "nsg01" {
  name                = "dpdwsnsg01"
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
  name                      = "dpdwsnic01"
  resource_group_name       = azurerm_resource_group.rg01.name
  location                  = azurerm_resource_group.rg01.location
  network_security_group_id = azurerm_network_security_group.nsg01.id
  ip_configuration {
    name                          = "dpdwsipc01"
    subnet_id                     = azurerm_subnet.vnetsub01.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip01.id
  }
}

resource "azurerm_storage_account" "sa01" {
  name                     = "dpdwssa01"
  location                 = azurerm_resource_group.rg01.location
  resource_group_name      = azurerm_resource_group.rg01.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_virtual_machine" "vm01" {
  name                  = "dpdwsvm01"
  resource_group_name   = azurerm_resource_group.rg01.name
  location              = azurerm_resource_group.rg01.location
  network_interface_ids = [azurerm_network_interface.nic01.id]
  vm_size               = "Standard_DS2_v2"

  storage_os_disk {
    name              = "dpdwswin01_os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_profile {
    computer_name  = "dpdwswin01"
    admin_username = "dpdadmin"
    admin_password = "DPD2019!"
  }

  os_profile_windows_config {
    provision_vm_agent = "true"
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = azurerm_storage_account.sa01.primary_blob_endpoint
  }
}