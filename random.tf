# Used to generate special names for storage account
resource "random_string" "random_0" {
  length  = 7
  upper   = false
  special = false
}
