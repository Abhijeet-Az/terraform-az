resource "azurerm_private_dns_zone" "dns_zone" {
  for_each            = toset(var.private_dns_zone_map)
  name                = each.key
  resource_group_name = var.dns_zone_rg_name
  lifecycle {
    prevent_destroy = true
  }
  timeouts {
    create = local.timeout_duration
    delete = local.timeout_duration
  }
}
