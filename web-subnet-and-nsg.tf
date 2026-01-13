resource "azurerm_subnet" "web_subnet" {
  name                 = "${local.resource_name_prefix}-web_subnet"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet_hub.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "web_subnet_nsg" {
  name                = "${local.resource_name_prefix}-web_subnet_nsg"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg1.name
}

resource "azurerm_subnet_network_security_group_association" "web_subnet_associate_nsg" {
  depends_on = [
    azurerm_network_security_rule.web_subnet_nsg_rule,
    azurerm_network_security_group.web_subnet_nsg,
  azurerm_subnet.web_subnet]
  network_security_group_id = azurerm_network_security_group.web_subnet_nsg.id
  subnet_id                 = azurerm_subnet.web_subnet.id
}

resource "azurerm_network_security_rule" "web_subnet_nsg_rule" {
  # We need to allow inbound HTTPS access from the Internet
  # This is because what our web-vmss sees is not the frontend ip of LB, but the actual IPs from clients
  name                        = "${local.resource_name_prefix}-web_subnet_nsg_rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"  # client port is ephemeral port
  destination_port_range      = "80" # matches the probe's port, so we don't need to configure another rule to allow AzureLoadBalancer
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg1.name
  network_security_group_name = azurerm_network_security_group.web_subnet_nsg.name
}
