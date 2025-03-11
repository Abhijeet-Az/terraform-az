// Common Variables
//**********************************************************************************************
variable "env_prefix" {
  type        = string
  description = "(Required) The env_prefix where resources will be deployed into. Part of the naming scheme."
}
variable "location" {
  type        = string
  description = "(Required) The cafoud region where resources will be deployed into."
}
variable "suffix" {
  type        = string
  description = "(Required) The instance count where the resource is being deployed ex- 001,002"
}
//**********************************************************************************************

// Optional Variables
//**********************************************************************************************
variable "tags" {
  description = "(Optional) A mapping of tags to assign to all resources."
  type        = map(any)
  default     = {}
}
variable "caf_resource_group_name" {
  description = "(Optional) The custom name of the resource group."
  type        = string
  default     = null
}
//**********************************************************************************************