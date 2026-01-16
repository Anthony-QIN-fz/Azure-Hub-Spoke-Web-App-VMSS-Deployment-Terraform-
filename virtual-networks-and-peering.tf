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

# Azure often treats subnet work as a “VNet update”, and while a VNet is in that Updating state, 
# Azure can reject a peering create/update. So this is an Azure problem
# Therefore in terraform we have to make peering 'depends_on' all actions that are deemed as 
# updating the VNet, such as the creation of subnets and association of NSGs and subnets

#Peering: Hub -> Spoke1
resource "azurerm_virtual_network_peering" "hub_to_spoke1" {
  name                      = "${local.resource_name_prefix}-hub_to_spoke1"
  resource_group_name       = azurerm_resource_group.rg1.name
  virtual_network_name      = azurerm_virtual_network.vnet_hub.name
  remote_virtual_network_id = azurerm_virtual_network.vnet_spoke1.id

  allow_virtual_network_access = true

  depends_on = [
    azurerm_subnet.bastion_subnet,
    azurerm_subnet.web_subnet,
    azurerm_subnet.app_subnet,
    azurerm_subnet_nat_gateway_association.app_subnet_associate_natgw,
    azurerm_subnet_network_security_group_association.app_subnet_associate_nsg,
    azurerm_subnet_network_security_group_association.web_subnet_associate_nsg
  ]
}

#Peering: Spoke1 -> Hub
resource "azurerm_virtual_network_peering" "spoke1_to_hub" {
  name                      = "${local.resource_name_prefix}-spoke1_to_hub"
  resource_group_name       = azurerm_resource_group.rg1.name
  virtual_network_name      = azurerm_virtual_network.vnet_spoke1.name
  remote_virtual_network_id = azurerm_virtual_network.vnet_hub.id

  allow_virtual_network_access = true

  depends_on = [
    azurerm_subnet.bastion_subnet,
    azurerm_subnet.web_subnet,
    azurerm_subnet.app_subnet,
    azurerm_subnet_nat_gateway_association.app_subnet_associate_natgw,
    azurerm_subnet_network_security_group_association.app_subnet_associate_nsg,
    azurerm_subnet_network_security_group_association.web_subnet_associate_nsg
  ]
}
