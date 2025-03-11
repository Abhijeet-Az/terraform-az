// Sets up Key Vault with virtual network filter if it's set to true
//**********************************************************************************************
resource "azurerm_key_vault_secret" "caf_keyvault_secret" {
  for_each     = var.caf_key_vault_secret_map
  name         = each.value.secret_name
  value        = each.value.secret_value
  key_vault_id = var.key_vault_id

  timeouts {
    create = local.timeout_duration
    delete = local.timeout_duration
  }
  lifecycle {
    prevent_destroy = true
  }
}
