provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}
resource "azurerm_resource_group" "rg01" {
  name     = "yarg001"
  location = var.location
}
resource "azurerm_virtual_network" "vnet01" {
  name                = "thisvnet01"
  resource_group_name = azurerm_resource_group.rg01.name
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.rg01.location
}

resource "azurerm_subnet" "vnetsub01" {
  name                 = "dpdwsvnetsub01"
  resource_group_name  = azurerm_resource_group.rg01.name
  virtual_network_name = azurerm_virtual_network.vnet01.name
  address_prefix       = "10.10.1.0/24"
}

resource "azurerm_subnet" "vnetsub02" {
  name                 = "dpdwsvnetsub02"
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
