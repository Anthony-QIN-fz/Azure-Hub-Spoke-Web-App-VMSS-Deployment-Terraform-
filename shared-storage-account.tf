# This storage account is meant to be shared by all resources within this project
# Here, by 'shared' I mean 'shared' by resources within our private network. Still not publicly accessible

resource "azurerm_storage_account" "shared_storage_account" {
  # name of storage account has to be lowercased alphanumeric and globally unique
  name                     = "storageaccount${random_string.random_0.result}"
  location                 = var.resource_group_location
  resource_group_name      = azurerm_resource_group.rg1.name
  account_replication_type = var.storage_account_replication_type
  account_tier             = var.storage_account_tier
  # No need to specify account kind as it is GPv2 by default
}

resource "azurerm_storage_container" "shared_blob_container" {
  name               = "sharedblobcontainer"
  storage_account_id = azurerm_storage_account.shared_storage_account.id

  # There are three values for container_access_type: "private", "blob" and "container"
  # Note that they all must be lower-cased
  container_access_type = "private"
}

resource "azurerm_storage_blob" "shared_blobs" {
  name                   = var.container_file_name
  type                   = "Block" # the most commonly used type for almost all general-purpose object storage
  storage_account_name   = azurerm_storage_account.shared_storage_account.name
  storage_container_name = azurerm_storage_container.shared_blob_container.name
  source                 = "${path.module}/${var.scripts_folder_name}/${var.container_file_name}"
}
