resource "azurerm_resource_group" "rg02" {
  name      = "yarg002"
  location  = var.location
}
resource "azurerm_virtual_network" "partnervnet01" {
  name                = "wsvnet02"
  resource_group_name = azurerm_resource_group.rg02.name
  address_space       = ["10.11.0.0/16"]
  location            = azurerm_resource_group.rg02.location
}

resource "azurerm_subnet" "partnervnetsub01" {
  name                 = "wsvnetsub01"
  resource_group_name  = azurerm_resource_group.rg02.name
  virtual_network_name = azurerm_virtual_network.partnervnet01.name
  address_prefix       = "10.11.1.0/24"
}

resource "azurerm_subnet" "partnervnetsub02" {
  name                 = "wsvnetsub02"
  resource_group_name  = azurerm_resource_group.rg02.name
  virtual_network_name = azurerm_virtual_network.partnervnet01.name
  address_prefix       = "10.11.2.0/24"
}

