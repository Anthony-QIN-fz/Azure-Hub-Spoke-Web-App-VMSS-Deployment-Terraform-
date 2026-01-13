resource "azurerm_linux_virtual_machine_scale_set" "web_vmss" {
  name                 = "${local.resource_name_prefix}-web_vmss"
  location             = var.resource_group_location
  resource_group_name  = azurerm_resource_group.rg1.name
  instances            = 2
  health_probe_id      = azurerm_lb_probe.web_lb_probe.id
  computer_name_prefix = "webvmss"

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
    name = "${local.resource_name_prefix}-web_vmss-nic"

    primary = true

    # We're not gonna associate an NSG on this VMSS as Microsoft suggests that:
    # for sanity, we generally should avoid associating NSGs at subnets and NICs simultaneously

    ip_configuration {
      name                                   = "ip_config1" # This name only needs to be unique within this NIC
      primary                                = true
      subnet_id                              = azurerm_subnet.web_subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.web_lb_backend.id]
    }
  }

  sku = "Standard_B2s"

  admin_username = "admin_user" # We should make this a variable too (likewise for the username below). However, for brevity, we'll just leave it as-is


  # The best practice is to store the key in Key Vault
  admin_ssh_key {
    username   = "admin_user"
    public_key = file("${path.module}/${var.ssh_keys_folder_name}/${var.web_vmss_ssh_key_public_name}") # Here, we use 'ssh-keygen' to generate keys 
  }

  custom_data = base64encode(templatefile("${path.module}/${var.scripts_folder_name}/${var.web_vmss_script_name}", {
    storage_account_name = azurerm_storage_account.shared_storage_account.name
    container_name       = azurerm_storage_container.shared_blob_container.name
    file_name            = var.container_file_name
  }))

  upgrade_mode = "Rolling"

  rolling_upgrade_policy {
    max_batch_instance_percent              = 15
    max_unhealthy_instance_percent          = 25
    max_unhealthy_upgraded_instance_percent = 5
    pause_time_between_batches              = "PT0S"
  }

  identity {
    type = "SystemAssigned" # assign a Managed Identity, with which it can access our private blob container
  }
}

# Allow this web vmss to read blob data
resource "azurerm_role_assignment" "web_vmss_blob_reader" {
  role_definition_name = "Storage Blob Data Reader"
  scope                = azurerm_storage_account.shared_storage_account.id
  principal_id         = azurerm_linux_virtual_machine_scale_set.web_vmss.identity[0].principal_id # the identity block is a list

}
