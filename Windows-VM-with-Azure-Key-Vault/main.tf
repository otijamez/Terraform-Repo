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

locals {
  resource_group_name = var.resource_group_name
  location = "east us2"
  admin_username = "security"
}

data "azurerm_client_config" "current" {
  
}
resource "azurerm_resource_group" "RGroup" {
  name     = local.resource_group_name
  location = local.location
}

resource "azurerm_virtual_network" "VNET" {
  name                = "vnet-1"
  address_space       = ["10.0.0.0/16"]
  location            = local.location
  resource_group_name = local.resource_group_name

  depends_on = [ azurerm_resource_group.RGroup ]
}

resource "azurerm_subnet" "SUB1" {
  name                 = "frontend"
  resource_group_name  = local.resource_group_name
  virtual_network_name = "vnet-1"
  address_prefixes     = ["10.0.1.0/24"]

  depends_on = [ azurerm_virtual_network.VNET ]
}

resource "azurerm_public_ip" "PIP" {
  name                = "twist-pip"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static"

  depends_on = [ azurerm_resource_group.RGroup ]
}

resource "azurerm_network_interface" "NIC" {
  name                = "vm-1-Nic"
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

resource "azurerm_windows_virtual_machine" "Machine" {
  name                = "vm-1"
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = "Standard_DS1_V2"
  admin_username      = local.admin_username
  admin_password      = azurerm_key_vault_secret.vmpassword.value
  network_interface_ids = [
    azurerm_network_interface.NIC.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  depends_on = [ azurerm_network_interface.NIC,
  azurerm_key_vault_secret.vmpassword ]
}

resource "azurerm_key_vault" "vaults" {
  name                       = "vaults56567"
  location                   = local.location
  resource_group_name        = local.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]
  }
  depends_on = [ azurerm_resource_group.RGroup ]
}

resource "azurerm_key_vault_secret" "vmpassword" {
  name         = "vmpassword"
  value        = "Admin@123"
  key_vault_id = azurerm_key_vault.vaults.id
  depends_on = [ azurerm_key_vault.vaults ]
}
