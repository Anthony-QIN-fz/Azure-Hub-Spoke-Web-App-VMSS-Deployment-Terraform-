resource "azurerm_monitor_autoscale_setting" "web_vmss_autoscaling" {
  name                = "${local.resource_name_prefix}-web_vmss_autoscaling"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = var.resource_group_location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.web_vmss.id

  # Default Profile: Scale out by 1 when CPU > 80%; Scale in by 1 when CPU < 30%
  profile {
    name = "default"

    capacity {
      default = 3
      minimum = 1
      maximum = 5
    }

    # Scale out
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.web_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 80
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT2M"
      }
    }

    # Scale in
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.web_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT2M"
      }

    }
  }

}
