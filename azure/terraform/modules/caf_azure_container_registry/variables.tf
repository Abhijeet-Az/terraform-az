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
variable "caf_azure_container_registry_rg_name" {
  description = "(Required) The name of container registry resource group."
}

variable "azurecontainerregistry_subnet_id" {
  description = "(Required) The subnet ID of the subnet to create a private endpoint"
}

variable "caf_acr_private_dns_zone_id" {
  type        = list(string)
  description = "(Required) The DNS Zone ID of the subnet to link the private endpoint"
  default     = ["/subscriptions/85d89dad-c139-48fb-b3ed-8902eb8b0a3a/resourceGroups/rg-shared-eastus-001/providers/Microsoft.Network/privateDnsZones/privatelink.azurecr.io"]
}

variable "caf_acr_private_dns_zone_is_manual" {
  type    = bool
  default = false
}

variable "caf_acr_private_dns_zone_subresource_name" {
  type    = list(string)
  default = ["registry"]
}
//**********************************************************************************************


// Optional Variables
//**********************************************************************************************
variable "tags" {
  description = "(Optional) A mapping of tags to assign to all resources."
  type        = map(any)
  default     = {}
}

variable "caf_azure_container_registry_sku" {
  type        = string
  description = "(Optional) Desire SKU for the Container Registry. Can be Basic, Standard or Premium."
  default     = "Basic"
}
variable "caf_azure_container_registry_public_network_access_enabled" {
  description = "(Optional) Whether public network access is allowed for the container registry."
  default     = true
}
variable "caf_azure_container_registry_anonymous_pull_enabled" {
  description = "(Optional) Whether allows anonymous (unauthenticated) pull access to this Container Registry? Defaults to false. This is only supported on resources with the Standard or Premium SKU."
  type        = bool
  default     = false
}
variable "caf_azure_container_registry_network_rule_bypass_option" {
  description = "(Optional) Whether to allow trusted Azure services to access a network restricted Container Registry? Possible values are None and AzureServices. Defaults to AzureServices."
  type        = string
  default     = "AzureServices"
}
variable "caf_azure_container_registry_network_rule_set_default_action" {
  type        = string
  description = "(Optional) The behaviour for requests matching no rules. Either Allow or Deny. Defaults to Deny"
  default     = "Deny"
}
variable "caf_azure_container_registry_admin_enabled" {
  description = "(Optional) Specifies whether the admin user is enabled."
  default     = true
}
variable "caf_azure_container_registry_content_trust_enabled" {
  description = "(Optional) Enables content trust for the sign of images being pushed to the registry"
  type        = bool
  default     = false
}

//**********************************************************************************************


// Local Variables
//**********************************************************************************************
locals {
  timeout_duration = "2h"
}
//**********************************************************************************************