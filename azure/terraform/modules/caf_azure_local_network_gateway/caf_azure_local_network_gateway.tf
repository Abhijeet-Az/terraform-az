resource "azurerm_local_network_gateway" "local_network_gateway" {
  for_each            = var.local_network_gateway_map
  name                = "lgw-${each.value.purpose}-${var.location}-${each.value.suffix_lgw}"
  resource_group_name = var.lgw_rg_name
  location            = var.location
  gateway_address     = each.value.lgw_gateway_address
  address_space       = each.value.local_address_space

  lifecycle {
    prevent_destroy = true
  }
}