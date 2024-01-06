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
  description = "Please enter the Resource Group name"
}
variable "storage_account_name" {
type = string
description = "please enter the storage account name"
}

locals {
  resource_group_name = var.resource_group_name
  location = "east us"
}

resource "azurerm_resource_group" "RGroup" {
  name     = local.resource_group_name
  location = local.location
}

resource "azurerm_storage_account" "storage-account" {
  name                     = var.storage_account_name
  resource_group_name      = local.resource_group_name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  depends_on = [ azurerm_resource_group.RGroup ]
}

resource "azurerm_storage_container" "container" {
  name                  = "container"
  storage_account_name  = var.storage_account_name
  container_access_type = "blob"
  depends_on = [ azurerm_storage_account.storage-account ]
}

resource "azurerm_storage_blob" "blob-storage" {
  name                   = "blob.txt"
  storage_account_name   = var.storage_account_name
  storage_container_name = "container"
  type                   = "Block"
  source                 = "blob.txt"
  depends_on = [ azurerm_storage_container.container ]
}
