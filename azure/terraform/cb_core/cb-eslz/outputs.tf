output "caf_la_workspace" {
  value     = azurerm_log_analytics_workspace.la_workspace
  sensitive = true
}

output "caf_am_workspace" {
  value     = azurerm_monitor_workspace.am_workspace
  sensitive = true
}

output "slack_kv_action_group" {
  value     = azurerm_monitor_action_group.action_group
  sensitive = true
}