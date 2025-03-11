// Common Variables
//**********************************************************************************************
variable "location" {
  description = "(Required) The cafoud region where resources will be deployed into."
}
//**********************************************************************************************


// Required Variables
//**********************************************************************************************
variable "conn_rg_name" {
  description = "(Required) The resource group for the Local Network Gateway."
}

variable "gateway_connection_map" {
  description = "(Required) The Map of Connections"
  type = map(object({
    connection_name            = string
    virtual_network_gateway_id = string
    local_network_gateway_id   = string
    shared_key                 = string
    connection_type            = string
    connection_protocol        = string
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