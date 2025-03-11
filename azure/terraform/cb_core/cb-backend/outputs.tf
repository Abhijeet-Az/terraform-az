output "caf_vnet_id" {
  value = module.caf_vnet.caf_vnet_id
}

# To be checked separately
#output "caf_vnet_subnet" {
#  value = module.caf_vnet.caf_vnet_subnet 
#}
#
#output "resource_group_name" {
#  description = "Name of the resource group"
#  value       = module.caf_resource_group.caf_resource_group.name
#  
#}