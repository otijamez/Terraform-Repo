
resource "azurerm_virtual_network" "VNET" {
  name                = "VNET"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rgroup.location
  resource_group_name = azurerm_resource_group.rgroup.name

  subnet {
    name           = "app-subnet"
    address_prefix = "10.0.1.0/24"
    security_group = azurerm_network_security_group.nsg-1.id
  }
  subnet {
    name           = "subnet2"
    address_prefix = "10.0.2.0/24"
  } 
  depends_on = [ 
    azurerm_resource_group.rgroup 
  ] 
}
