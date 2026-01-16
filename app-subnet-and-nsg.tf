resource "azurerm_subnet" "app_subnet" {
  name                 = "${local.resource_name_prefix}-app_subnet"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet_spoke1.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_network_security_group" "app_subnet_nsg" {
  name                = "${local.resource_name_prefix}-app_subnet_nsg"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg1.name
}

resource "azurerm_subnet_network_security_group_association" "app_subnet_associate_nsg" {
  depends_on = [
    azurerm_network_security_group.app_subnet_nsg,
  azurerm_subnet.app_subnet]
  network_security_group_id = azurerm_network_security_group.app_subnet_nsg.id
  subnet_id                 = azurerm_subnet.app_subnet.id
}

# Notice that the default NSG rules already include AllowLoadBalancerIn and AllowVNetIn (Here, VNet refers
# to "the same VNet" + "all peered VNets" + "all connected on-prems networks").
# Therefore, the following rules are in fact redundant


# # Health probe's packets come from an Azure-owned address represented by the service tag "AzureLoadBalancer"
# resource "azurerm_network_security_rule" "app_subnet_nsg_rule_allow_probe_in" {
#   name                        = "${local.resource_name_prefix}-app_subnet_nsg_rule_allow_probe_in"
#   priority                    = 100
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "AzureLoadBalancer"
#   destination_address_prefix  = "*"
#   resource_group_name         = azurerm_resource_group.rg1.name
#   network_security_group_name = azurerm_network_security_group.app_subnet_nsg.name
# }

# resource "azurerm_network_security_rule" "app_subnet_nsg_rule_allow_webvmss_in" {
#   name                        = "${local.resource_name_prefix}-app_subnet_nsg_rule_allow_webvmss_in"
#   priority                    = 101
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "80"
#   source_address_prefix       = azurerm_subnet.web_subnet.address_prefixes[0]
#   destination_address_prefix  = "*"
#   resource_group_name         = azurerm_resource_group.rg1.name
#   network_security_group_name = azurerm_network_security_group.app_subnet_nsg.name
# }


