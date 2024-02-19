
resource "azurerm_public_ip" "LB_pip" {
  name                = "LB-pip"
  location            = azurerm_resource_group.rgroup.location
  resource_group_name = azurerm_resource_group.rgroup.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "App_LB" {
  name                = "App-LB"
  location            = azurerm_resource_group.rgroup.location
  resource_group_name = azurerm_resource_group.rgroup.name
  sku = "Standard"
  
  frontend_ip_configuration {
    name                 = "front-pip"
    public_ip_address_id = azurerm_public_ip.LB_pip.id
  }
  depends_on = [ 
    azurerm_public_ip.LB_pip 
    ]
}

resource "azurerm_lb_probe" "H_probe" {
  loadbalancer_id = azurerm_lb.App_LB.id
  name            = "H-probe"
  port            = 80
  depends_on = [ 
    azurerm_lb.App_LB
     ]
}

resource "azurerm_lb_rule" "LB_Rule" {
  loadbalancer_id                = azurerm_lb.App_LB.id
  name                           = "LB-Rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "front-pip"
  backend_address_pool_ids = [ azurerm_lb_backend_address_pool.bckend_pool.id ]
  probe_id = azurerm_lb_probe.H_probe.id

  depends_on = [
     azurerm_lb.App_LB
      ]
}

resource "azurerm_lb_backend_address_pool" "bckend_pool" {
  loadbalancer_id = azurerm_lb.App_LB.id
  name            = "bckend-pool"

  depends_on = [ 
    azurerm_lb.App_LB 
    ]
}

resource "azurerm_lb_backend_address_pool_address" "appvm_addr1" {
  name                    = "appvm-addr1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bckend_pool.id
  virtual_network_id      = azurerm_virtual_network.VNET.id
  ip_address              = azurerm_network_interface.NIC.private_ip_address

  depends_on = [
     azurerm_lb_backend_address_pool.bckend_pool ,
     azurerm_resource_group.rgroup
  ]
}

resource "azurerm_lb_backend_address_pool_address" "appvm_addr2" {
  name                    = "appvm-addr2"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bckend_pool.id
  virtual_network_id      = azurerm_virtual_network.VNET.id
  ip_address              = azurerm_network_interface.NIC2.private_ip_address

  depends_on = [ 
    azurerm_lb_backend_address_pool.bckend_pool ,
    azurerm_resource_group.rgroup
  ]
}

