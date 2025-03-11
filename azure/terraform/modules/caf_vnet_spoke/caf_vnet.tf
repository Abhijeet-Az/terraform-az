// Virtual Network
//**********************************************************************************************
resource "azurerm_virtual_network" "core_vnet" {
  name                = "vnet-${var.env_prefix}-${var.location}-${var.suffix}"
  resource_group_name = var.resource_group_name
  address_space       = var.core_vnet_address_space
  location            = var.location
  lifecycle {
    prevent_destroy = true
  }
  //tags                = var.tags
}
resource "azurerm_subnet" "caf_vnet_subnet" {
  for_each             = var.caf_vnet_subnet_enabled ? var.caf_vnet_subnet_combined : {}
  virtual_network_name = azurerm_virtual_network.core_vnet.name
  name                 = "snet-${each.value.caf_vnet_purpose}-${var.env_prefix}-${var.location}-${var.suffix}"
  resource_group_name  = azurerm_virtual_network.core_vnet.resource_group_name
  address_prefixes     = each.value.address_prefixes
  lifecycle {
    prevent_destroy = true
  }
}
//**********************************************************************************************


// Peering spoke to Remote VNets A - B
//**********************************************************************************************

resource "azurerm_virtual_network_peering" "core_peering" {
  name                         = "peer-${var.env_prefix}-${var.location}-shared-${var.suffix}" //"peer-to-shared-services"
  resource_group_name          = azurerm_virtual_network.core_vnet.resource_group_name
  virtual_network_name         = azurerm_virtual_network.core_vnet.name
  remote_virtual_network_id    = var.caf_vnet_core_shared_services_peering_network_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = true

  # 'allow_gateway_transit' must be set to false for vnet Global Peering
  allow_gateway_transit = false
}
