resource "azurerm_log_analytics_workspace" "la_workspace" {
  name                            = "la-${var.environment}-${var.location}-${var.suffix}"
  location                        = var.location
  resource_group_name             = module.caf_resource_group.caf_resource_group.name
  allow_resource_only_permissions = true
  sku                             = var.la_sku
  retention_in_days               = var.la_retention
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_monitor_workspace" "am_workspace" {
  name                = "am-${var.environment}-${var.location}-${var.suffix}"
  resource_group_name = module.caf_resource_group.caf_resource_group.name
  location            = var.location
  lifecycle {
    prevent_destroy = true
  }
}