terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.85.0"
    }
  }
}

provider "azurerm" {
 subscription_id = 
  tenant_id       =
  client_id       =
  client_secret   =
  features {}
}

variable "resource_group_name" {
  type = string
  description = "Please enter the resource group name"
}
variable "admin_password" {
  type = string
  description = "Please enter your new password"
}

locals {
  resource_group_name = var.resource_group_name
  location = "east us2"
  admin_username = "security"
}

resource "azurerm_resource_group" "RGroup" {
  name     = local.resource_group_name
  location = local.location
}

resource "azurerm_virtual_network" "VNET" {
  name                = "VNET"
  address_space       = ["10.0.0.0/16"]
  location            = local.location
  resource_group_name = local.resource_group_name

  depends_on = [ azurerm_resource_group.RGroup ]
}

resource "azurerm_subnet" "SUB1" {
  name                 = "subnet"
  resource_group_name  = local.resource_group_name
  virtual_network_name = "vnet"
  address_prefixes     = ["10.0.1.0/24"]

  depends_on = [ azurerm_virtual_network.VNET ]
}

resource "azurerm_public_ip" "PIP" {
  name                = "PIP"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static"

  depends_on = [ azurerm_resource_group.RGroup ]
}

resource "azurerm_network_interface" "NIC" {
  name                = "NIC"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.SUB1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.PIP.id
  }

  depends_on = [ 
    azurerm_virtual_network.VNET,
    azurerm_public_ip.PIP
    ]
}

resource "azurerm_linux_virtual_machine" "linux_VM" {
  name                = "Test-vm-Linux"
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = "Standard_DS1_V2"
  admin_username      = "security"
  admin_password = var.admin_password
  disable_password_authentication = false 
  network_interface_ids = [
    azurerm_network_interface.NIC.id,
  ]
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
  depends_on = [ azurerm_network_interface.NIC ]
}
