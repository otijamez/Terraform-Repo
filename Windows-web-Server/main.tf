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
variable "storage_account_name" {
  type = string
  description = "Please enter the Storage Account name"
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

resource "azurerm_managed_disk" "data-Disk" {
  name                 = "Data-Disk"
  location             = local.location
  resource_group_name  = local.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "16"

  depends_on = [ azurerm_resource_group.RGroup ]
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm-datadisk" {
  managed_disk_id    = azurerm_managed_disk.data-Disk.id
  virtual_machine_id = azurerm_windows_virtual_machine.Machine.id
  lun                = "0"
  caching            = "ReadWrite"
depends_on = [ 
  azurerm_managed_disk.data-Disk,
  azurerm_windows_virtual_machine.Machine 
]

}
resource "azurerm_windows_virtual_machine" "Machine" {
  name                = "Test-VM"
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = "Standard_DS1_V2"
  admin_username      = local.admin_username
  admin_password      = var.admin_password
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

  depends_on = [ azurerm_network_interface.NIC ]
}

resource "azurerm_storage_account" "Storage_account" {
  name                     = var.storage_account_name
  resource_group_name      = local.resource_group_name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  depends_on = [azurerm_resource_group.RGroup]
}

resource "azurerm_storage_container" "contain1" {
  name                  = "contain1"
  storage_account_name  = var.storage_account_name
  container_access_type = "blob"
  depends_on = [azurerm_storage_account.Storage_account]
}

resource "azurerm_storage_blob" "iis_config" {
  name                   = "iis-config.ps1"
  storage_account_name   = var.storage_account_name
  storage_container_name = "contain1"
  type                   = "Block"
  source                 = "iis-config.ps1"
  depends_on = [ azurerm_storage_container.contain1 ]
}

resource "azurerm_virtual_machine_extension" "vm-extn" {
  name                 = "testvm-extension"
  virtual_machine_id   = azurerm_windows_virtual_machine.Machine.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  depends_on = [
    azurerm_storage_blob.iis_config,
    azurerm_virtual_machine_data_disk_attachment.vm-datadisk
    ]

  settings = <<SETTINGS
{
"fileUris": ["https://${azurerm_storage_account.Storage_account.name}.blob.core.windows.net/contain1/iis-config.ps1"],
 "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file iis-config.ps1"
}
SETTINGS
} 
