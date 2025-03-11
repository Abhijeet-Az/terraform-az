// Virtual Network
//**********************************************************************************************
resource "azurerm_virtual_network" "core_vnet" {
  name                = "vnet-${var.env_prefix}-${var.location}-${var.suffix}"
  resource_group_name = var.resource_group_name
  address_space       = var.core_vnet_address_space
  location            = var.location
  //tags                = var.tags
}
resource "azurerm_subnet" "caf_vnet_subnet" {
  for_each             = var.caf_vnet_subnet_enabled ? var.caf_vnet_subnet_combined : {}
  virtual_network_name = azurerm_virtual_network.core_vnet.name
  name                 = each.value.subnet_name
  resource_group_name  = azurerm_virtual_network.core_vnet.resource_group_name
  address_prefixes     = each.value.address_prefixes

  dynamic "delegation" {
    for_each = each.value.delegation_needed == true ? [each.value.delegation] : []
    content {
      name = each.value.delegation.name
      service_delegation {
        actions = [each.value.delegation.delegation_allowed_actions]
        name    = each.value.delegation.delegation_name
      }
    }
  }
  lifecycle {
    prevent_destroy = true
  }
}
//**********************************************************************************************


// Peering spoke to Remote VNets A - B
//**********************************************************************************************

resource "azurerm_virtual_network_peering" "core_peering" {
  for_each                     = var.sharedvnetpeermap
  name                         = "peer-shared-${var.location}-${each.value.name}-${each.value.suffix}" //"peer-to-shared-services"
  resource_group_name          = azurerm_virtual_network.core_vnet.resource_group_name
  virtual_network_name         = azurerm_virtual_network.core_vnet.name
  remote_virtual_network_id    = each.value.remote_virtual_network_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = false

  # 'allow_gateway_transit' must be set to false for vnet Global Peering
  allow_gateway_transit = true
}
