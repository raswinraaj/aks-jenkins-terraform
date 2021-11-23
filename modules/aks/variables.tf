variable "location" {

}

variable "resource_group_name" {

}

variable "public_ssh_key" {
  description = "An ssh key set in the main variables of the terraform-azurerm-aks module"
  default     = ""
}

variable "tags" {
  type = map(string)
  default = {}
}