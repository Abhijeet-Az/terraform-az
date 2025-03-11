resource "azurerm_policy_set_definition" "azure_policy_definition" {
  name                = "Azure Policies - Starter Kit"
  policy_type         = "Custom"
  display_name        = "Azure Policies - Starter Kit"
  management_group_id = data.azurerm_management_group.Mgmt_Group_CB.id


  dynamic "policy_definition_reference" {
    for_each = tomap({ for pol in local.policyids : pol.PolicyID => pol })
    content {
      policy_definition_id = policy_definition_reference.value.PolicyID
      parameter_values     = policy_definition_reference.value.Parameters
    }
  }
}

resource "azurerm_management_group_policy_assignment" "azure_policy_assignment_lz" {
  name                 = "Starter Kit Assignment"
  policy_definition_id = azurerm_policy_set_definition.azure_policy_definition.id
  management_group_id  = data.azurerm_management_group.Mgmt_Group_LZ.id
}

resource "azurerm_management_group_policy_assignment" "azure_policy_assignment_plat" {
  name                 = "Starter Kit Assignment"
  policy_definition_id = azurerm_policy_set_definition.azure_policy_definition.id
  management_group_id  = data.azurerm_management_group.Mgmt_Group_Platform.id
}