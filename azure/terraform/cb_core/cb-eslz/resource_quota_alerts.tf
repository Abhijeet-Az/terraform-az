resource "azurerm_user_assigned_identity" "resoure_quota_managed_id" {
  name                = "resource-quota-managed-id"
  resource_group_name = module.caf_resource_group.caf_resource_group.name
  location            = var.location
}

resource "azurerm_role_assignment" "reader" {
  for_each             = toset(var.resource_quota_subscription_ids)
  principal_id         = azurerm_user_assigned_identity.resoure_quota_managed_id.principal_id
  role_definition_name = "Reader"
  scope                = "/subscriptions/${each.value}"
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "resource_quota_alert" {
  name                    = "Resource Quota Alert"
  resource_group_name     = module.caf_resource_group.caf_resource_group.name
  location                = var.location
  description             = "Resource Quota Alert"
  enabled                 = true
  severity                = 3
  auto_mitigation_enabled = true
  evaluation_frequency    = "PT15M"
  window_duration         = "PT15M" # Time range over which the query will be run
  scopes                  = ["/subscriptions/${var.resource_quota_subscription_ids[0]}"]
  criteria {
    query = <<QUERY
let subscriptionIds = dynamic(${jsonencode(var.resource_quota_subscription_ids)});
arg("").QuotaResources 
| where subscriptionId in (subscriptionIds)
| where isnotempty(properties)
| mv-expand propertyJson = properties.value limit 400
| extend
    usage = propertyJson.currentValue,
    quota = propertyJson.['limit'],
    quotaName = tostring(propertyJson.['name'].localizedValue)
| extend usagePercent = toint(usage)*100 / toint(quota)| project-away properties| where location in~ ('${var.location}')| where usagePercent > 0
QUERY

    time_aggregation_method = "Maximum"
    metric_measure_column   = "usagePercent"
    operator                = "GreaterThan"
    threshold               = 70
    dimension {
      name     = "subscriptionId"
      operator = "Include"
      values   = ["*"]
    }
    dimension {
      name     = "quotaName"
      operator = "Include"
      values   = ["*"]
    }
    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }
  action {
    action_groups = [azurerm_monitor_action_group.action_group.id]
  }
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.resoure_quota_managed_id.id,
    ]
  }
}
