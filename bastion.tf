resource "azurerm_public_ip" "bastion_public_ip" {
  name                = "${local.resource_name_prefix}-bastion-public-ip"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = var.resource_group_location

  allocation_method = "Static" # All Standard SKU public IPs must be static
  sku               = "Standard"
}

resource "azurerm_bastion_host" "bastion_host" {
  name                = "${local.resource_name_prefix}-bastion-host"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = var.resource_group_location

  # Since we're using VNet Peering, we have to choose Standard Bastion as Basic does not support connecting to VMs in other VNets
  sku = "Standard"

  # With this on, we can connect to this Bastion using our local machine instead of Azure Portal only
  tunneling_enabled = true

  ip_configuration {
    name                 = "${local.resource_name_prefix}-bastion-ip-config"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_public_ip.id
  }
}
