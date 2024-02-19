
resource "azurerm_public_ip" "PIP1" {
  name                = "PIP"
  resource_group_name = azurerm_resource_group.rgroup.name
  location            = azurerm_resource_group.rgroup.location
  allocation_method   = "Static"

  depends_on = [ 
    azurerm_resource_group.rgroup 
  ]
}


resource "azurerm_public_ip" "PIP2" {
  name                = "PIP2"
  resource_group_name = azurerm_resource_group.rgroup.name
  location            = azurerm_resource_group.rgroup.location
  allocation_method   = "Static"

  depends_on = [
     azurerm_resource_group.rgroup 
  ]
}

