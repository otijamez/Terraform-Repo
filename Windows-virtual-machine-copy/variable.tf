variable "no_of_instances" {
  type = number 
  description = "Please enter the number of instances"
}
variable "storage_account_name" {
  type = string
  description = "Please enter the storage account name"
}
variable "resource_group_name" {
  type = string
  description = "Please enter the resource group name"
}
variable "admin_password" {
  type = string
  description = "Please enter new password (must include uppercase, a symbol, a number and must be at least 8 characters)"
}
