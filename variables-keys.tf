variable "ssh_keys_folder_name" {
  description = "The folder where ssh keys are stored"
  type        = string
}

variable "web_vmss_ssh_key_public_name" {
  description = "The name of the public key of web vmss"
  type        = string
}

variable "web_vmss_ssh_key_private_name" {
  description = "The name of the private key of web vmss"
  type        = string
}

variable "app_vmss_ssh_key_public_name" {
  description = "The name of the public key of app vmss"
  type        = string
}

variable "app_vmss_ssh_key_private_name" {
  description = "The name of the private key of app vmss"
  type        = string
}
