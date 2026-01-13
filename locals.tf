locals {
  resource_name_prefix = "${var.business_department}-${var.environment}"
  default_tags = {
    department = var.business_department
    env        = var.environment
  }

  non_bastion_subnet_inbound_rules = {

  }


}
