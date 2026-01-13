resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet_hub.name

  address_prefixes = ["10.0.2.0/26"]
}

# For Bastion Subnet, NSGs are optional. 

