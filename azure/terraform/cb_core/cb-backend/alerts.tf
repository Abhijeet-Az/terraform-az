resource "azurerm_monitor_scheduled_query_rules_alert_v2" "log_alert" {
  name                    = "kv-secret-update-${var.environment}-${var.location}-${var.azure_config[var.environment].env_prefix}"
  resource_group_name     = module.caf_resource_group.caf_resource_group.name
  location                = var.location
  description             = "Alert when a secret update occurs in the Key Vaults."
  enabled                 = true
  severity                = 3
  auto_mitigation_enabled = true
  evaluation_frequency    = "PT5M"
  window_duration         = "PT5M" # Time range over which the query will be run
  scopes = [
    module.caf_azure_keyvault.caf_keyvault.id
  ]
  criteria {
    query = <<QUERY
AzureDiagnostics
| where ResourceType == "VAULTS" 
| where OperationName == "SecretUpdate" or OperationName == "SecretSet"
| project
    TimeGenerated,
    Resource,
    OperationName,
    ResultDescription,
    identity_claim_unique_name_s,
    id_s
| order by TimeGenerated desc
QUERY

    time_aggregation_method = "Count"
    operator                = "GreaterThan"
    threshold               = 0
    dimension {
      name     = "id_s"
      operator = "Include"
      values   = ["*"]
    }
  }
  action {
    action_groups = [data.terraform_remote_state.shared.outputs.slack_kv_action_group.id]
  }
}
