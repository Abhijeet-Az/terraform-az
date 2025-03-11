// Common Variables
//**********************************************************************************************
variable "env_prefix" {
  description = "(Required) The env_prefix where resources will be deployed into. Part of the naming scheme."
}
variable "location" {
  description = "(Required) The cafoud region where resources will be deployed into."
}
variable "tenant_id" {
  description = "(Required) The tenant ID that the resources will reside in."
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
variable "caf_keyvault_rg_name" {
  description = "(Required) The resource group for the keyvault."
}
//**********************************************************************************************


// Optional Variables
//**********************************************************************************************

variable "caf_keyvault_sku_name" {
  description = "(Optional) The Name of the SKU used for Key Vault"
  type        = string
  default     = "standard"
}
variable "caf_keyvault_enabled_for_deployment" {
  type        = bool
  description = "(Optional) Boolean to enable vms to be able to fetch from keyvault."
  default     = true
}
variable "caf_keyvault_enabled_for_disk_encryption" {
  type        = bool
  description = "(Optional) Boolean to enable vms to use keyvault certificates for disk encryption."
  default     = true
}
variable "caf_keyvault_enable_rbac_authorization" {
  type        = bool
  description = "(Optional) Boolean to enable RBAC authorization model"
  default     = true
}
variable "caf_keyvault_public_network_access_enabled" {
  type        = bool
  description = "(Optional) Boolean to enable public access for key vault resources"
  default     = true
}
variable "caf_keyvault_enabled_for_template_deployment" {
  type        = bool
  description = "(Optional) Boolean to enable azure resource manager deployments to be able to fetch from keyvault."
  default     = false
}
variable "caf_keyvault_soft_delete_enabled" {
  description = "(Optional) When soft-delete is enabled, resources marked as deleted resources are retained for a specified period (90 days by default)."
  type        = bool
  default     = true
}
variable "caf_keyvault_purge_protection_enabled" {
  type        = bool
  description = "(Optional) When purge protection is on, a vault or an object in the deleted state cannot be purged until the retention period has passed."
  default     = true
}

variable "caf_keyvault_private_dns_zone_id" {
  type        = list(string)
  description = "The DNS zone ID of the subnet to create the private endpoint A record"
  default     = ["/subscriptions/85d89dad-c139-48fb-b3ed-8902eb8b0a3a/resourceGroups/rg-shared-eastus-001/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"]
}
variable "azurekeyvault_subnet_id" {
  type        = string
  description = "The subnet ID of the subnet to create the private endpoint"
}
variable "caf_key_vault_private_dns_zone_is_manual" {
  type    = bool
  default = false
}
variable "caf_key_vault_private_dns_zone_subresource_name" {
  type        = list(string)
  description = "The sub resource name to create the private endpoint"
  default     = ["vault"]
}

variable "diag_log_analytics_workspace_id" {
  description = "Diagnotic Log Analytics Workspace ID"
}
//**********************************************************************************************

// Local Variables
//**********************************************************************************************
locals {
  timeout_duration = "2h"
}
//**********************************************************************************************