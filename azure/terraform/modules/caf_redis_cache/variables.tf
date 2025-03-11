// Common Variables Azure Redis Cache
//**********************************************************************************************
variable "env_prefix" {
  description = "The env_prefix where resources will be deployed into. Part of the naming scheme."
}
variable "suffix" {
  description = "A unique identifier for the deployment. Part of the naming scheme."
}
variable "location" {
  description = "The cafoud region where resources will be deployed into."
}
variable "caf_application" {
  type        = string
  description = "(Required) The name of the application where the resource is being deployed"
}
//*******************************************************************************************


// Required Variables Azure Redis Cache
//*******************************************************************************************
variable "caf_redis_cache_rg_name" {
  description = "Name of resource group name"
  type        = string
}

// Optional Variables Azure Redis Cache
//*******************************************************************************************
variable "caf_redis_cache_sku" {
  description = "(Required) The SKU of Redis to use. Possible values are Basic, Standard and Premium"
  default     = "Standard"
}
variable "caf_redis_cache_capacity" {
  description = "(Required) The size of the Redis cache to deploy. Valid values for a SKU family of C (Basic/Standard) are 0, 1, 2, 3, 4, 5, 6, and for P (Premium) family are 1, 2, 3, 4, 5"
  default     = 2
}

variable "caf_redis_cache_private_dns_zone_ids" {
  description = "(Optional) Specifies the list of Private DNS Zones to incafude within the private_dns_zone_group."
  type        = list(string)
  default     = ["/subscriptions/85d89dad-c139-48fb-b3ed-8902eb8b0a3a/resourceGroups/rg-shared-eastus-001/providers/Microsoft.Network/privateDnsZones/privatelink.redis.cache.windows.net"]
}
variable "caf_redis_cache_identity_type" {
  description = "(Required) Specifies the type of Managed Service Identity that should be configured on this ServiceBus Namespace. Possible values are SystemAssigned, UserAssigned, SystemAssigned, UserAssigned (to enable both)."
  type        = string
  default     = "SystemAssigned"
}
variable "caf_redis_cache_identity_ids" {
  description = " (Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this ServiceBus namespace."
  type        = list(string)
  default     = null
}
variable "caf_redis_cache_public_network_access_enabled" {
  description = "(Optional) Is public network access enabled for the Redis Cache? Defaults to true."
  type        = bool
  default     = false
}

variable "caf_redis_cache_minimum_tls_version" {
  description = "(Optional) The minimum supported TLS version for this Redis Cache. Valid values are: 1.0, 1.1 and 1.2. The current default minimum TLS version is 1.2."
  type        = number
  default     = 1.2
}
variable "caf_redis_cache_private_dns_zone_name" {
  description = "(Optional) Specifies the name of Private DNS Zones to incafude within the private_dns_zone_group."
  type        = string
  default     = "privatelink.servicebus.windows.net"
}

variable "caf_redis_cache_private_endpoint_subnet_id" {
  description = "(Optional) Specifies the ID of subnet to create the Private Endpoint in."
  type        = string
}

variable "caf_redis_cache_family" {
  description = "(Required) The SKU family/pricing group to use. Valid values are C (for Basic/Standard SKU family) and P (for Premium)"
  type        = string
  default     = "C"
}

variable "caf_redis_cache_non_ssl_enabled" {
  description = "(Optional) Enable the non-SSL port (6379) - disabled by default."
  type        = bool
  default     = false
}
//*******************************************************************************************