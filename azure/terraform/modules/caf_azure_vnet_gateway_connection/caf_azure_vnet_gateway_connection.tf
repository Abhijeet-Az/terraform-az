resource "azurerm_virtual_network_gateway_connection" "azure_vnet_gateway_connection" {
  for_each                   = var.gateway_connection_map
  name                       = each.value.connection_name
  location                   = var.location
  resource_group_name        = var.conn_rg_name
  dpd_timeout_seconds        = 45
  type                       = each.value.connection_type
  connection_protocol        = each.value.connection_protocol
  virtual_network_gateway_id = each.value.virtual_network_gateway_id
  local_network_gateway_id   = each.value.local_network_gateway_id

  shared_key = each.value.shared_key
  lifecycle {
    prevent_destroy = true
  }
}