# If we attach a VM/VMSS to the backend pool of a standard Internal LB,
# Azure will remove the default outbound access to the internet of the VM/VMSS
# In order to restore this outbound access to internet, we need a NAT Gateway

resource "azurerm_public_ip" "app_natgw_pubic_ip" {
  name                = "${local.resource_name_prefix}-app_natgw_pubic_ip"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = var.resource_group_location
  allocation_method   = "Static" # NAT Gateway's public ip must be static
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "app_natgw" {
  name                = "${local.resource_name_prefix}-app_natgw"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = var.resource_group_location
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "app_natgw_associate_public_ip" {
  nat_gateway_id       = azurerm_nat_gateway.app_natgw.id
  public_ip_address_id = azurerm_public_ip.app_natgw_pubic_ip.id
}

resource "azurerm_subnet_nat_gateway_association" "app_subnet_associate_natgw" {
  nat_gateway_id = azurerm_nat_gateway.app_natgw.id
  subnet_id      = azurerm_subnet.app_subnet.id
}
