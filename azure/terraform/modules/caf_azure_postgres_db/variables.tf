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
variable "caf_azure_postgresql_rg_name" {
  description = "(Required) The name of container registry resource group."
}

variable "azure_psql_subnet_id" {
  description = "(Required) The subnet ID of the subnet to create a private endpoint"
}

variable "caf_psql_private_dns_zone_id" {
  type        = list(string)
  description = "(Required) The DNS Zone ID of the subnet to link the private endpoint"
  default     = ["/subscriptions/85d89dad-c139-48fb-b3ed-8902eb8b0a3a/resourceGroups/rg-shared-eastus-001/providers/Microsoft.Network/privateDnsZones/privatelink.postgres.database.azure.com"]
}

variable "caf_psql_private_dns_zone_is_manual" {
  type    = bool
  default = false
}

variable "caf_psql_private_dns_zone_subresource_name" {
  type    = list(string)
  default = ["postgresqlServer"]
}
//**********************************************************************************************


// Optional Variables
//**********************************************************************************************
variable "tags" {
  description = "(Optional) A mapping of tags to assign to all resources."
  type        = map(any)
  default     = {}
}

variable "caf_azure_postgresql_sku" {
  type        = string
  description = "(Required) Specifies the SKU Name for this PostgreSQL Server. The name of the SKU, follows the tier + family + cores pattern (e.g. B_Gen4_1, GP_Gen5_8). For more information see the product documentation. Possible values are B_Gen4_1, B_Gen4_2, B_Gen5_1, B_Gen5_2, GP_Gen4_2, GP_Gen4_4, GP_Gen4_8, GP_Gen4_16, GP_Gen4_32, GP_Gen5_2, GP_Gen5_4, GP_Gen5_8, GP_Gen5_16, GP_Gen5_32, GP_Gen5_64, MO_Gen5_2, MO_Gen5_4, MO_Gen5_8, MO_Gen5_16 and MO_Gen5_32"
  default     = "B_Standard_B1ms"
}
variable "caf_azure_postgresql_public_network_access_enabled" {
  description = "(Optional) Whether public network access is allowed for the container registry."
  default     = true
}
variable "caf_azure_postgresql_version" {
  description = "(Required) Specifies the version of PostgreSQL to use. Valid values are 9.5, 9.6, 10, 10.0, 10.2 and 11. Changing this forces a new resource to be created."
  type        = string
  default     = "16"
}
variable "psql_administrator_login" {
  description = "(Required) Administrator Username for PostGreSQL"
  type        = string
}

variable "psql_administrator_password" {
  description = "(Required) Administrator Password for PostGreSQL"
  type        = string
}

variable "caf_azure_postgresql_network_rule_set_default_action" {
  type        = string
  description = "(Optional) The behaviour for requests matching no rules. Either Allow or Deny. Defaults to Deny"
  default     = "Deny"
}
variable "caf_azure_postgresql_admin_enabled" {
  description = "(Optional) Specifies whether the admin user is enabled."
  default     = false
}

variable "backup_retention_days" {
  description = "The backup retention days for the PostgreSQL Flexible Server. Possible values are between 7 and 35 days."
  default     = 7
}
//**********************************************************************************************


// Local Variables
//**********************************************************************************************
locals {
  timeout_duration = "2h"
}
//**********************************************************************************************