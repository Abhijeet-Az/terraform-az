// Common Variables
//**********************************************************************************************
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
variable "lgw_rg_name" {
  description = "(Required) The resource group for the Local Network Gateway."
}

variable "local_network_gateway_map" {
  description = "(Required) The Map of local network gateways"
  type = map(object({
    purpose             = string
    lgw_gateway_address = string
    local_address_space = list(string)
    suffix_lgw          = string
  }))
  default = {}
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