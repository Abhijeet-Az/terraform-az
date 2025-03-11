// Common Variables
//**********************************************************************************************
variable "env_prefix" {
  type        = string
  description = "(Required) The env_prefix where resources will be deployed into. Part of the naming scheme."
}
variable "caf_vnet_name" {
  description = "(Optional) The custom name of the vnet."
  type        = string
  default     = null
}
variable "location" {
  type        = string
  description = "(Required) The cafoud region where resources will be deployed into."
}
variable "suffix" {
  type        = string
  description = "(Required) The instance count where the resource is being deployed ex- 001,002"
}
variable "caf_application" {
  type        = string
  description = "(Required) The name of the application where the resource is being deployed"
}
//**********************************************************************************************


// Required Variables
//**********************************************************************************************
variable "resource_group_name" {
  type = string
}

variable "core_vnet_address_space" {
  type        = list(string)
  description = "(Required) The address space for the virtual network."
}


// Optional Variables
//**********************************************************************************************
variable "tags" {
  description = "(Optional) A mapping of tags to assign to all resources."
  type        = map(any)
  default     = {}
}

variable "caf_vnet_core_shared_services_peering_network_id" {
  description = "The Network ID of the shared services Vnet"
  type        = string
  default     = "/subscriptions/85d89dad-c139-48fb-b3ed-8902eb8b0a3a/resourceGroups/rg-shared-eastus-001/providers/Microsoft.Network/virtualNetworks/vnet-shared-eastus-001"
}
//**********************************************************************************************

variable "caf_vnet_subnet_prefixes" {
  description = "(Optiona) Creates subnet for vnet"
  type        = list(string)
  default     = [""]
}
variable "caf_vnet_subnet_enabled" {
  description = "(Optional) Do you want to create subnet with vnet?.defaults to false"
  type        = bool
  default     = true
}
variable "caf_vnet_subnet_combined" {
  description = "(Optional) creating extra subnet for vnet"
  //type = map(any)
  type = map(object({
    address_prefixes = list(string)
    caf_vnet_purpose = string
  }))
  default = {}
}

locals {
  private_dns_zone_names = {
    crowdbotics = {
      name = "crowdbotics.com"
    }
    container = {
      name = "privatelink.azurecr.io"
    }
    PostGres = {
      name = "privatelink.postgres.database.azure.com"
    }
    Blob = {
      name = "privatelink.blob.core.windows.net"
    }
    Redis = {
      name = "privatelink.redis.cache.windows.net"
    }
    ServiceBus = {
      name = "privatelink.servicebus.windows.net"
    }
    KeyVault = {
      name = "privatelink.vaultcore.azure.net"
    }
  }
}