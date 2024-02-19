

resource "azurerm_storage_account" "storage-account" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rgroup.name
  location                 = azurerm_resource_group.rgroup.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  depends_on = [ 
    azurerm_resource_group.rgroup 
  ]
}

resource "azurerm_storage_container" "container" {
  name                  = "container" 
  storage_account_name  = var.storage_account_name
  container_access_type = "blob"

  depends_on = [  
    azurerm_storage_account.storage-account 
  ]
}

resource "azurerm_storage_blob" "blob-storage" {
  name                   = "iis-config.ps1"
  storage_account_name   = var.storage_account_name
  storage_container_name = "container"
  type                   = "Block"
  source                 = "iis-config.ps1"

  depends_on = [ 
    azurerm_storage_container.container 
  ]
}
