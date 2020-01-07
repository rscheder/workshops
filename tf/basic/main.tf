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

# enable network peering between two virtual networks

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

# comment this section until pip01 is created - data can only retrieved after creation
data "azurerm_public_ip" "pip01" {
  name                = azurerm_public_ip.pip01.name
  resource_group_name = azurerm_resource_group.rg01.name
}

output "public_ip_address" {
  value = data.azurerm_public_ip.pip01.ip_address
}

resource "azurerm_network_security_group" "nsg01" {
  name                = "wsnsg01"
  resource_group_name = azurerm_resource_group.rg01.name
  location            = azurerm_resource_group.rg01.location

  security_rule {
    name                        = "rdp"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "3389"
  # source_address_prefix       = data.azurerm_public_ip.pip01.ip_address
  source_address_prefix       = "*" 
    destination_address_prefix  = "VirtualNetwork"
  }

  security_rule {
    name                        = "ssh"
    priority                    = 101
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
  # source_address_prefix       = data.azurerm_public_ip.pip01.ip_address
  source_address_prefix       = "*" 
    destination_address_prefix  = "VirtualNetwork"
  }
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
  # private_ip_address            = 10.10.0.8  
    public_ip_address_id          = azurerm_public_ip.pip01.id
  }
}

resource "azurerm_storage_account" "sa01" {
  name                     = "wssa01"
  location                 = azurerm_resource_group.rg01.location
  resource_group_name      = azurerm_resource_group.rg01.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_virtual_machine" "vm01" {
    name                  = "wsvm01"
    location              = azurerm_resource_group.rg01.location
    resource_group_name   = azurerm_resource_group.rg01.name
    network_interface_ids = [azurerm_network_interface.nic01.id]
    vm_size               = "Standard_B2s"

    storage_os_disk {
        name              = "wsvm01_osdisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Debian"
        offer     = "debian-10"
        sku       = "10"
        version   = "latest"
    }

  # storage_image_reference {
  # publisher = "MicrosoftWindowsServer"
  # offer     = "WindowsServer"
  # sku       = "2016-Datacenter"
  # version   = "latest"
  # }

    os_profile {
        computer_name  = "myvm"
        admin_username = "RSCHEDER"
    }
 # os_profile {
 #    computer_name  = "wswin01"
 #    admin_username = "admin"
 #    admin_password = "T0p$ecr3t!"
 # }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/RSCHEDER/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCynaLDGihHV9t7Vw9TEcsM1QDhvi6vc9LnUqcikL5kKOLhUuVHQKrOkBOf813uPKBLcq9IqaT7IsjJg6wSNgGo0K1q2qD+h+fM/nACyjIc8tXFDHO0It8fMKaZlwye2Qe1+y/nMBNBaJty3sfPdocJFrmqKSJxRPmBYOtSIPcqA6Mr6YGH+wEECXBPjCbmDiMho34jhk9uQoo6uFUAsB4Ls5d4fc7QSkyungUKz5t77iK8rQB4GEavd0EurK9pVDBGgRuTtABz7aig0iQ3i7woOibS8tWT8G4PCfE8NUPnxrD2+uoO/hpDgUUYD58ncL2+tCh3IAdBRMhhHhQ8pDi7"
        }
    }
      boot_diagnostics {
        enabled = "true"
        storage_uri = azurerm_storage_account.sa01.primary_blob_endpoint
    }
}