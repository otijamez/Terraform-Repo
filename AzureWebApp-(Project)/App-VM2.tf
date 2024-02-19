
resource "azurerm_network_interface" "NIC2" {
  name                = "NIC2"
  location            = azurerm_resource_group.rgroup.location
  resource_group_name = azurerm_resource_group.rgroup.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.app-subnet.id 
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.PIP2.id
  }

  depends_on = [ 
    azurerm_virtual_network.VNET,
    azurerm_public_ip.PIP2
    ]
}

resource "azurerm_windows_virtual_machine" "app_VM2" {
  name                = "app-VM2"
  resource_group_name = azurerm_resource_group.rgroup.name
  location            = azurerm_resource_group.rgroup.location
  size                = "Standard_DS1_V2"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.NIC2.id
  ]
  availability_set_id = azurerm_availability_set.Aset.id

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
  depends_on = [ 
    azurerm_network_interface.NIC2
    ]
}

resource "azurerm_virtual_machine_extension" "vm-extn2" {
  name                 = "appvm2-extn"
  virtual_machine_id   = azurerm_windows_virtual_machine.app_VM2.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  depends_on = [
    azurerm_storage_blob.blob-storage, azurerm_windows_virtual_machine.app_VM2
    ]

  settings = <<SETTINGS
{
"fileUris": ["https://${azurerm_storage_account.storage-account.name}.blob.core.windows.net/container/iis-config.ps1"],
 "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file iis-config.ps1"
}
SETTINGS
} 
