resource "azurerm_monitor_autoscale_setting" "app_vmss_autoscaling" {
  name                = "${local.resource_name_prefix}-app_vmss_autoscaling"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = var.resource_group_location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.app_vmss.id

  # Recurrence profile: Increase the count from 10
  profile {
    name = "Increase capacity from 3am to 4am every day"

    capacity {
      default = 7
      minimum = 6
      maximum = 8
    }

    recurrence {
      timezone = "Singapore Standard Time"
      days     = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
      hours    = [3]
      minutes  = [0]
    }

    # A recurrence profile does not need a metric rule though it can be added if necessary
  }


  # Recurrence profile: Restore to the default autoscaling profile outside 3am to 4am
  profile {
    name = "default"

    capacity {
      default = 3
      minimum = 1
      maximum = 5
    }

    recurrence {
      timezone = "Singapore Standard Time"
      days     = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
      hours    = [4]
      minutes  = [0]
    }

    # Scale out
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.app_vmss.id
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
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.app_vmss.id
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






