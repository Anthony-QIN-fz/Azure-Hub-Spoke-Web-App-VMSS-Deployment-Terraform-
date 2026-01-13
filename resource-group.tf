# Whenever we wanna refer to this rg's name, we have to use 
# azurerm_resource_group.rg.name. We must not use var.resource_group_name
# This is to avoid dependency issues

resource "azurerm_resource_group" "rg1" {
  name     = var.resource_group_name
  location = var.resource_group_location
  tags     = local.default_tags
}
