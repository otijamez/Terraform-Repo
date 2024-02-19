
resource "azurerm_network_security_group" "nsg-1" {
  name                = "NSG"
  location            = azurerm_resource_group.rgroup.location 
  resource_group_name = azurerm_resource_group.rgroup.name

  security_rule {
    name                       = "HTTP-Rule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "RDP-Rule"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  depends_on = [
     azurerm_resource_group.rgroup
   ]
}
