// Sets up Key Vault with virtual network filter if it's set to true
//**********************************************************************************************
resource "azurerm_key_vault" "caf_keyvault" {
  name                = "kv-${var.env_prefix}-${var.caf_application}-${var.location}-${var.suffix}"
  location            = var.location
  resource_group_name = var.caf_keyvault_rg_name
  tenant_id           = var.tenant_id
  sku_name            = var.caf_keyvault_sku_name

  enabled_for_deployment          = var.caf_keyvault_enabled_for_deployment
  enabled_for_disk_encryption     = var.caf_keyvault_enabled_for_disk_encryption
  enabled_for_template_deployment = var.caf_keyvault_enabled_for_template_deployment

  enable_rbac_authorization     = var.caf_keyvault_enable_rbac_authorization
  public_network_access_enabled = var.caf_keyvault_public_network_access_enabled

  #soft_delete_enabled = var.caf_keyvault_soft_delete_enabled //Deprecated by Azure

  # This should allow scheduled purging of the key vault on destroy.
  purge_protection_enabled = var.caf_keyvault_purge_protection_enabled


  //tags = var.tags

  timeouts {
    create = local.timeout_duration
    delete = local.timeout_duration
  }
  lifecycle {
    ignore_changes = [
      name
    ]
    prevent_destroy = true
  }
}
// Sets up the private endpoint for the Key Vault
//**********************************************************************************************
resource "azurerm_private_endpoint" "caf_keyvault_private_endpoint" {
  name                = "pe-kv-${var.caf_application}-${var.env_prefix}-${var.location}-${var.suffix}"
  location            = var.location
  resource_group_name = var.caf_keyvault_rg_name
  subnet_id           = var.azurekeyvault_subnet_id

  private_dns_zone_group {
    name                 = "privatelink.vaultcore.azure.net"
    private_dns_zone_ids = var.caf_keyvault_private_dns_zone_id
  }

  private_service_connection {
    name                           = azurerm_key_vault.caf_keyvault.name
    private_connection_resource_id = azurerm_key_vault.caf_keyvault.id
    is_manual_connection           = var.caf_key_vault_private_dns_zone_is_manual
    subresource_names              = var.caf_key_vault_private_dns_zone_subresource_name
  }

  lifecycle {
    ignore_changes = [
      name, private_service_connection
    ]
  }

  //tags = var.tags
}
//**********************************************************************************************

resource "azurerm_monitor_diagnostic_setting" "caf_azure_kv_diagnostic_setting" {
  name                       = "diag-${var.caf_application}-${var.env_prefix}-${var.location}-${var.suffix}"
  target_resource_id         = azurerm_key_vault.caf_keyvault.id
  log_analytics_workspace_id = var.diag_log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }
}