# This is a public load balancer 

resource "azurerm_public_ip" "web_lb_public_ip" {
  name                = "${local.resource_name_prefix}-web_lb_public_ip"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = var.resource_group_location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "web_lb" {
  name                = "${local.resource_name_prefix}-web_lb"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = var.resource_group_location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "web_lb_public_ip1"
    public_ip_address_id = azurerm_public_ip.web_lb_public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "web_lb_backend" {
  name            = "${local.resource_name_prefix}-web_lb_backend"
  loadbalancer_id = azurerm_lb.web_lb.id
}

resource "azurerm_lb_probe" "web_lb_probe" {
  name            = "${local.resource_name_prefix}-web_lb_probe"
  loadbalancer_id = azurerm_lb.web_lb.id
  port            = 80 # We will choose http
}

resource "azurerm_lb_rule" "web_lb_rule" {
  name                           = "${local.resource_name_prefix}-web_lb_rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.web_lb.frontend_ip_configuration[0].name
  loadbalancer_id                = azurerm_lb.web_lb.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.web_lb_backend.id]
  probe_id                       = azurerm_lb_probe.web_lb_probe.id
}
