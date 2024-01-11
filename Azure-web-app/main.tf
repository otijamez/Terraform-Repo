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
variable "App_service_plan_name" {
  type = string
  description = "Please enter the App Service Plan name"
}
variable "Web_App_name" {
  type = string
  description = "Please enter the Web App name"
}

locals {
  resource_group_name = var.resource_group_name
  location = "east us2"
}

resource "azurerm_resource_group" "RGroup" {
  name = local.resource_group_name
  location = local.location
}

resource "azurerm_service_plan" "App_plan" {
  name                = var.App_service_plan_name
  resource_group_name = local.resource_group_name
  location            = local.location
  sku_name            = "F1"
  os_type             = "Windows"
  depends_on = [ azurerm_resource_group.RGroup ]
}

resource "azurerm_windows_web_app" "Webapp" {
  name                = var.Web_App_name
  resource_group_name = local.resource_group_name
  location            = local.location
  service_plan_id     = azurerm_service_plan.App_plan.id

  site_config {
    always_on = false
  }
}
