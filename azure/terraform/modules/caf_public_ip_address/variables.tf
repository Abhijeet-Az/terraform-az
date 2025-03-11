// Common Variables
//**********************************************************************************************
variable "env_prefix" {
  description = "(Required) The environment where resources will be deployed into. Part of the naming scheme."
}
variable "location" {
  description = "(Required) The cafoud region where resources will be deployed into."
}
variable "caf_application" {
  type        = string
  description = "(Required) The name of the application where the resource is being deployed"
}
variable "suffix" {
  type        = string
  description = "(Required) The instance count where the resource is being deployed ex- 001,002"
}
//**********************************************************************************************


// Required Variables
//**********************************************************************************************

variable "pip_rg_name" {
  description = "(Required) The resource group for the DNS Resolver."
}

variable "public_ip_map" {
  description = "Map of the Public IP Configurations"
  type = map(object({
    purpose           = string
    pip_zones         = list(string)
    allocation_method = string
    pip_sku           = string
    version           = string
  }))
  default = {
  }
}
//**********************************************************************************************

// Local Variables
//**********************************************************************************************
locals {
  timeout_duration = "2h"
}
//**********************************************************************************************