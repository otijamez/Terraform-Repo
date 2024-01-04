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

variable "pip_name" {
  type = list 
  default = ["Test-pip", "Prod-pip", "Dev-pip"]
}
variable "resource_group_name" {
  type = string
  description = "Please enter the resource group name"
}

locals {
  resource_group_name = var.resource_group_name
  location = "eastus"
}

resource "azurerm_resource_group" "Resource_Group" {
  name     = local.resource_group_name
  location = local.location
}

resource "azurerm_public_ip" "Public_IP" {
  name                = var.pip_name[count.index]
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static"
  depends_on = [ azurerm_resource_group.Resource_Group ]
  count = 3
}
