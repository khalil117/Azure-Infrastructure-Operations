variable "prefix" {
  description = "The prefix that will be used for all resoruces."
  default = "demokhalil"
}
variable "resource_group_name" {
  description = "rsg for the virtual machine's name which will be created"
  default     = "Azuredevops"
  
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default     = "South Central US"
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."
  default = {
    envirement = "Development"
  }
}

variable "vm-count" {
  description = "The amount of VMs that will be created."
}

variable "vm-admin-username" {
  description = "The username of the VM's admin."
  # default = "alphaadmin"
}

variable "vm-admin-password" {
  description = "The password of the VM's admin."
  # default = "alphaP@ss"
}

variable "vm-update-count" {
  description = "The amount of VMs that will be created when a specific one is updating the OS system."
  default     = 5
}

variable "vm-fault-count" {
  description = "The amount of VMs that will be created when a specific one is failing or having any kind of issues."
  default     = 3
}
variable "image_id" {
  description = "Enter the ID for the image which will be used for creating the Virtual Machines"
  default     = "/subscriptions/SUBSCRIPTION_ID/resourceGroups/RESOURCE_GROUP_NAME/providers/Microsoft.Compute/images/IMAGE_NAME"
}
