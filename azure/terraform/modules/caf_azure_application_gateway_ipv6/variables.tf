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
variable "appgw_rg_name" {
  description = "(Required) The resource group for the DNS Resolver."
}

variable "appgw_subnet_id" {
  description = "name of the subnet which will host the application gateway"
}

variable "frontend_port_map" {
  description = "Map of the Frontend Port Configurations"
  type = map(object({
    frontend_port_name = string
    port               = number
  }))
  default = {}
}



variable "ssl_certificate_password" {
  description = "Password for the SSL used for the App Gateway HTTPS Listeners"
  type        = string
}

variable "backend_address_pool_map" {
  description = "Map of the Backend Pool Configurations"
  type = map(object({
    backend_address_pool_name       = string
    backend_address_pool_ip_address = list(string)
  }))
  default = {}
}

variable "backend_http_settings_map" {
  description = "Map of the Backend HTTP Setting Configurations"
  type = map(object({
    name      = string
    host_name = string
  }))
  default = {}
}

variable "http_listener_map" {
  description = "Map of the Backend HTTP Listener Configurations"
  type = map(object({
    http_listener_name             = string
    frontend_port_name             = string
    protocol                       = string
    frontend_ip_configuration_name = string
    host_names                     = list(string)
  }))
  default = {}
}

variable "routing_rule_map" {
  description = "Map of the Backend HTTP Listener Configurations"
  type = map(object({
    routing_rule_name         = string
    listener_name             = string
    priority                  = string
    backend_address_pool_name = string
    http_setting_name         = string
  }))
  default = {}
}

variable "appgw_max_capacity" {
  description = "Maximum capacity for autoscaling. Accepted values are in the range 2 to 125."
  default     = "10"
}
variable "appgw_min_capacity" {
  description = "Minimum capacity for autoscaling. Accepted values are in the range 0 to 100."
  default     = "1"
}
variable "appgw_sku" {
  description = "The Name of the SKU to use for this Application Gateway. Possible values are Standard_Small, Standard_Medium, Standard_Large, Standard_v2, WAF_Medium, WAF_Large, and WAF_v2"
  default     = "Standard_v2"
}
variable "appgw_tier" {
  description = "The Tier of the SKU to use for this Application Gateway. Possible values are Standard, Standard_v2, WAF and WAF_v2"
  default     = "Standard_v2"
}
variable "probe_map" {
  description = "Map of the Probe Map Configurations"
  type = map(object({
    probe_name     = string
    probe_path     = string
    probe_map_bool = bool
  }))
  default = {}
}

variable "frontend_ip_map" {
  description = "Map of the Frontend IP Configuration"
  type = map(object({
    name                 = string
    public_ip_address_id = string
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