resource "azurerm_cdn_profile" "profile" {
  name                = "profile-${var.environment}-${var.location}-${var.suffix}"
  location            = var.location
  resource_group_name = module.caf_resource_group.caf_resource_group.name
  sku                 = var.cdn_sku
}
resource "azurerm_cdn_endpoint" "resources" {
  for_each            = var.cdn_config
  name                = "endpoint-${each.key}-${var.location}-${var.suffix}"
  profile_name        = azurerm_cdn_profile.profile.name
  location            = var.location
  resource_group_name = azurerm_cdn_profile.profile.resource_group_name
  is_http_allowed     = false
  origin_host_header  = "${each.value.storage_account_name}.blob.core.windows.net"
  origin {
    name      = "blob"
    host_name = "${each.value.storage_account_name}.blob.core.windows.net"
  }
}