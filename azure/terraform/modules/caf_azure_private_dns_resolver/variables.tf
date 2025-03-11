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
variable "dns_resolver_rg_name" {
  description = "(Required) The resource group for the DNS Resolver."
}

variable "dns_resolver_vnet_id" {
  description = "(Required) The Virtual Network for the DNS Resolver."
}

variable "dns_resolver_inbound_subnet_id" {
  description = "(Required) The inbound Subnet for the DNS Resolver."
}
//**********************************************************************************************


// Optional Variables
//**********************************************************************************************
variable "dns_resolver_inbound_ip_address" {
  description = "(Required) The Inbound Private IP Address for the DNS Resolver."
}

//**********************************************************************************************

// Local Variables
//**********************************************************************************************
locals {
  timeout_duration = "2h"
}
//**********************************************************************************************