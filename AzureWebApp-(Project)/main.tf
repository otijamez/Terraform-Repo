variable "resource_group_name" {
  type = string
  description = "Please enter the resource group name" 
}
variable "admin_password" {
  type = string
  description = "Please enter your new password"
}
variable "admin_username" {
  type = string
  description = "Please enter your username"
}
variable "storage_account_name" {
type = string
description = "please enter the storage account name"
}

resource "azurerm_resource_group" "rgroup" {
name = var.resource_group_name
location = "East us"
}

data "azurerm_subnet" "app-subnet" {
name = "app-subnet"
resource_group_name = var.resource_group_name
virtual_network_name = azurerm_virtual_network.VNET.name 
}
