resource "azurerm_resource_group" "default" {
  name     = local.resource_group
  location = local.resource_group_location
  tags     = local.tags
}
