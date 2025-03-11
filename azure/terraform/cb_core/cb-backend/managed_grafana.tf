resource "azurerm_log_analytics_workspace" "la_workspace" {
  name                            = "la-${var.environment}-${var.azure_config[var.environment].suffix}"
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
  name                = "am-${var.environment}-${var.azure_config[var.environment].suffix}"
  resource_group_name = module.caf_resource_group.caf_resource_group.name
  location            = var.location
  lifecycle {
    prevent_destroy = true
  }
}
resource "azurerm_dashboard_grafana" "grafana" {
  name                              = "grafana-${var.environment}-${var.azure_config[var.environment].suffix}"
  resource_group_name               = module.caf_resource_group.caf_resource_group.name
  location                          = var.location
  api_key_enabled                   = true
  deterministic_outbound_ip_enabled = true
  public_network_access_enabled     = true
  grafana_major_version             = 10

  identity {
    type = "SystemAssigned"
  }

  azure_monitor_workspace_integrations {
    resource_id = azurerm_monitor_workspace.am_workspace.id
  }
}

resource "azurerm_role_assignment" "datareaderrole" {
  scope              = data.terraform_remote_state.shared.outputs.caf_am_workspace.id
  role_definition_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/b0d8363b-8ddd-447d-831f-62ca05bff136"
  principal_id       = azurerm_dashboard_grafana.grafana.identity.0.principal_id
}
