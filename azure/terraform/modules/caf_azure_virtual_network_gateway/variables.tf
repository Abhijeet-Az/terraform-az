// Common Variables
//**********************************************************************************************
variable "env_prefix" {
  description = "(Required) The environment where resources will be deployed into. Part of the naming scheme."
}
variable "location" {
  description = "(Required) The cafoud region where resources will be deployed into."
}
variable "suffix" {
  type        = string
  description = "(Required) The instance count where the resource is being deployed ex- 001,002"
}
//**********************************************************************************************


// Required Variables
//**********************************************************************************************
variable "vgw_rg_name" {
  description = "(Required) The resource group for the Virtual Network Gateway."
}

variable "vgw_sku" {
  description = "(Required) The Virtual Network for the DNS Resolver."
}

variable "vgw_pip_id" {
  description = "(Required) The Public IP ID of the IP to be associated with the Gateway"
}

variable "vgw_subnet_id" {
  description = "(Required) The Subnet of the Virtual Network Gateway"
}

//**********************************************************************************************


// Optional Variables
//**********************************************************************************************

//**********************************************************************************************

// Local Variables
//**********************************************************************************************
locals {
  timeout_duration = "2h"
}
//**********************************************************************************************