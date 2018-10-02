##############################################################################
# Variables File
# 
# Here is where we store the default values for all the variables used in our
# Terraform code. If you create a variable with no default, the user will be
# prompted to enter it (or define it via config file or command line flags.)

variable "ssh_key" {
  description = "SSH key for connecting to our Red Hat instance"
}

variable "ssh_key_path" {
  description = "Path to your ssh key on the local system."
}

variable "ssh_pubkey" {
  description = "Public half of SSH key for connecting to our Red Hat instance."
}

variable "resource_group" {
  description = "The name of your Azure Resource Group."
  default     = "Terraform-Ansible"
}

variable "prefix" {
  description = "This prefix will be included in the name of some resources."
  default     = "tfguide"
}

variable "hostname" {
  description = "Virtual machine hostname. Used for local hostname, DNS, and storage-related names."
  default     = "catapp"
}

variable "location" {
  description = "The region where the virtual network is created."
  default     = "centralus"
}

variable "virtual_network_name" {
  description = "The name for your virtual network."
  default     = "vnet"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.0.10.0/24"
}

variable "storage_account_tier" {
  description = "Defines the storage tier. Valid options are Standard and Premium."
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Defines the replication type to use for this storage account. Valid options include LRS, GRS etc."
  default     = "LRS"
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_A0"
}

variable "image_publisher" {
  description = "Name of the publisher of the image (az vm image list)"
  default     = "RedHat"
}

variable "image_offer" {
  description = "Name of the offer (az vm image list)"
  default     = "RHEL"
}

variable "image_sku" {
  description = "Image SKU to apply (az vm image list)"
  default     = "7.3"
}

variable "image_version" {
  description = "Version of the image to apply (az vm image list)"
  default     = "latest"
}

variable "admin_username" {
  description = "Administrator user name"
  default     = "adminuser"
}

variable "admin_password" {
  description = "Administrator password"
  default     = "Adminpassword123!"
}