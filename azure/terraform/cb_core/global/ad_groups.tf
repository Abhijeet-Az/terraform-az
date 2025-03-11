resource "azuread_group" "azure_ad_group" {
  for_each         = var.azure_ad_group_map
  display_name     = each.value.azure_ad_group_name
  owners           = local.azure_ad_default_group_owner
  security_enabled = true
  members          = each.value.azuread_group_members
}


resource "azurerm_role_assignment" "role_assignment_mg" {
  for_each = { for idx, val in local.role_assignments : "${val.group_name}-${val.role_name}" => val }

  scope                = data.azurerm_management_group.mgmt_group[each.value.scope_mgt_key].id
  role_definition_name = each.value.role_name
  principal_id         = azuread_group.azure_ad_group[each.value.group_name].object_id
}
