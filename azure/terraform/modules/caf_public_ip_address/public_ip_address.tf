resource "azurerm_public_ip" "public_ip_address" {
  for_each            = var.public_ip_map
  name                = "pip-${each.value.purpose}-${var.env_prefix}-${var.location}-${var.suffix}"
  resource_group_name = var.pip_rg_name
  location            = var.location
  allocation_method   = each.value.allocation_method
  sku                 = each.value.pip_sku
  zones               = each.value.pip_zones
  ip_version          = each.value.version

  timeouts {
    create = local.timeout_duration
    delete = local.timeout_duration
  }
  lifecycle {
    prevent_destroy = true
  }
}
