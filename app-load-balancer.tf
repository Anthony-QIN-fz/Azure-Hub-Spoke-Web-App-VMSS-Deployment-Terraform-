# This is an internal load balancer

resource "azurerm_lb" "app_lb" {
  name                = "${local.resource_name_prefix}-app_lb"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = var.resource_group_location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "app_lb_private_ip1"
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    private_ip_address            = "10.1.1.10"
    subnet_id                     = azurerm_subnet.app_subnet.id
  }
}

resource "azurerm_lb_backend_address_pool" "app_lb_backend" {
  name            = "${local.resource_name_prefix}-app_lb_backend"
  loadbalancer_id = azurerm_lb.app_lb.id
}

resource "azurerm_lb_probe" "app_lb_probe" {
  name            = "${local.resource_name_prefix}-app_lb_probe"
  protocol        = "Tcp"
  port            = 80
  loadbalancer_id = azurerm_lb.app_lb.id
}

resource "azurerm_lb_rule" "app_lb_rule" {
  name                           = "${local.resource_name_prefix}-app_lb_rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.app_lb.frontend_ip_configuration[0].name
  loadbalancer_id                = azurerm_lb.app_lb.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app_lb_backend.id]
  probe_id                       = azurerm_lb_probe.app_lb_probe.id
}
