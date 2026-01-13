variable "storage_account_tier" {
  type    = string
  default = "Standard"
}

variable "storage_account_replication_type" {
  type    = string
  default = "LRS"
}

variable "container_file_name" {
  description = "Names of the files to be uploaded to the blob container"
  type        = string
  default     = "web-to-app-proxy.conf"
}

