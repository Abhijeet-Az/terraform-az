data "azurerm_management_group" "mgmt_group" {
  for_each = var.mgmt_group_config
  name     = each.value.name
}