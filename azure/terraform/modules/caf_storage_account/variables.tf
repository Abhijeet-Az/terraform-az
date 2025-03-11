// Common Variables
//**********************************************************************************************
variable "env_prefix" {
  description = "(Required) The env_prefix where resources will be deployed into. Part of the naming scheme."
}
variable "suffix" {
  description = "(Required) A unique identifier for the deployment. Part of the naming scheme."
}
variable "location" {
  description = "(Required) The cafoud region where resources will be deployed into."
}
variable "caf_application" {
  type        = string
  description = "(Required) The name of the application where the resource is being deployed"
}
//**********************************************************************************************


// Required Variables
//**********************************************************************************************
variable "caf_storage_account_resource_group_name" {
  description = "(Required) The name of the resource group where the storage account will be deployed to."
}
//**********************************************************************************************

// Optional Variables
//**********************************************************************************************
variable "caf_storage_account_tier" {
  description = " (Required) Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid. Changing this forces a new resource to be created."
  type        = string
  default     = "Standard"
}

variable "caf_storage_account_replication_type" {
  description = " (Required) Defines the Replication type to use for this storage account. Valid options are LRS, GRS & ZRS."
  type        = string
  default     = "LRS"
}

variable "caf_storage_account_private_endpoint_subnet_id" {
  description = " (Optional) The Subnet ID of the resource to create the private endpoint in"
  type        = string
}

variable "caf_storage_account_private_dns_zone_ids" {
  description = "(Optional) The Private DNS Zone ID to create the private endpoint in"
  type        = list(string)
  default     = ["/subscriptions/85d89dad-c139-48fb-b3ed-8902eb8b0a3a/resourceGroups/rg-shared-eastus-001/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"]
}

variable "stg_container_map" {
  description = "Map of Storage Containers to be created"
  type        = map(any)
}

variable "cors_needed" {
}

variable "cors_rule" {
  description = "List of CORS rules to apply when CORS is needed."
  type = list(object({
    max_age_in_seconds = number
    exposed_headers    = list(string)
    allowed_headers    = list(string)
    allowed_methods    = list(string)
    allowed_origins    = list(string)
  }))
  default = []
}
