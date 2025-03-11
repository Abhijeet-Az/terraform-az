output "caf_vnet_subnet" {
  value = azurerm_subnet.caf_vnet_subnet
}

output "caf_vnet_id" {
  description = "ID of the Vnet"
  value       = azurerm_virtual_network.core_vnet.id
}

