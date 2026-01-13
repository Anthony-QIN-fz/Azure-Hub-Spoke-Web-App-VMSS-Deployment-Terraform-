resource "azurerm_virtual_network" "vnet_hub" {
  name                = "${local.resource_name_prefix}-${var.vnet_hub_name}"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  address_space       = ["10.0.0.0/16"]
  tags                = local.default_tags
}

resource "azurerm_virtual_network" "vnet_spoke1" {
  name                = "${local.resource_name_prefix}-${var.vnet_spoke1_name}"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  address_space       = ["10.1.0.0/16"]
  tags                = local.default_tags
}

#Peering: Hub -> Spoke1
resource "azurerm_virtual_network_peering" "hub_to_spoke1" {
  name                      = "${local.resource_name_prefix}-hub_to_spoke1"
  resource_group_name       = azurerm_resource_group.rg1.name
  virtual_network_name      = azurerm_virtual_network.vnet_hub.name
  remote_virtual_network_id = azurerm_virtual_network.vnet_spoke1.id

  allow_virtual_network_access = true
}

#Peering: Spoke1 -> Hub
resource "azurerm_virtual_network_peering" "spoke1_to_hub" {
  name                      = "${local.resource_name_prefix}-spoke1_to_hub"
  resource_group_name       = azurerm_resource_group.rg1.name
  virtual_network_name      = azurerm_virtual_network.vnet_spoke1.name
  remote_virtual_network_id = azurerm_virtual_network.vnet_hub.id

  allow_virtual_network_access = true
}
