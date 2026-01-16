resource "azurerm_linux_virtual_machine_scale_set" "app_vmss" {
  name                = "${local.resource_name_prefix}-app_vmss"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg1.name
  instances           = 2

  # VMSS must be after the lb rules because Azure doesn't allow VMSS to use a probe
  # that is not associated with any lb rule.
  depends_on      = [azurerm_lb_rule.app_lb_rule]
  health_probe_id = azurerm_lb_probe.app_lb_probe.id

  computer_name_prefix = "appvmss" # otherwise, terraform will automatically choose an invalid name

  os_disk {
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "10-lvm-gen2"
    version   = "latest"
  }

  network_interface {
    name = "${local.resource_name_prefix}-app_vmss-nic"

    primary = true

    ip_configuration {
      name                                   = "ip_config1"
      primary                                = true
      subnet_id                              = azurerm_subnet.app_subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.app_lb_backend.id]
    }
  }

  sku = "Standard_B2s"

  admin_username = "admin_user"

  admin_ssh_key {
    username   = "admin_user"
    public_key = file("${path.module}/${var.ssh_keys_folder_name}/${var.app_vmss_ssh_key_public_name}")
  }

  upgrade_mode = "Rolling"

  rolling_upgrade_policy {
    # batch size must be <= max unhealthy size 
    # because a whole batch might temporarily become unhealthy during the upgrade
    max_batch_instance_percent              = 15
    max_unhealthy_instance_percent          = 25
    max_unhealthy_upgraded_instance_percent = 5
    pause_time_between_batches              = "PT0S"
  }

  custom_data = base64encode(file("${path.module}/${var.scripts_folder_name}/${var.app_vmss_script_name}"))

}


