// Sets up an instance of Azure Container Registry (ACR)
//**********************************************************************************************
resource "azurerm_container_registry" "caf_azure_container_registry" {
  name                          = "acr${var.caf_application}${var.env_prefix}${var.suffix}"
  resource_group_name           = var.caf_azure_container_registry_rg_name
  location                      = var.location
  sku                           = var.caf_azure_container_registry_sku
  admin_enabled                 = var.caf_azure_container_registry_admin_enabled
  trust_policy_enabled          = var.caf_azure_container_registry_content_trust_enabled
  public_network_access_enabled = var.caf_azure_container_registry_public_network_access_enabled
  anonymous_pull_enabled        = var.caf_azure_container_registry_anonymous_pull_enabled
  network_rule_bypass_option    = var.caf_azure_container_registry_network_rule_bypass_option
  //tags                          = var.tags
  lifecycle {
    prevent_destroy = true
  }
  timeouts {
    create = local.timeout_duration
    delete = local.timeout_duration
  }

}
//**********************************************************************************************
resource "azurerm_private_endpoint" "caf_acr_private_endpoint" {
  count               = var.caf_azure_container_registry_sku == "Premium" ? 1 : 0
  name                = "pe-acr${var.caf_application}${var.env_prefix}${var.suffix}"
  location            = var.location
  resource_group_name = var.caf_azure_container_registry_rg_name
  subnet_id           = var.azurecontainerregistry_subnet_id

  private_dns_zone_group {
    name                 = "privatelink.azurecr.io"
    private_dns_zone_ids = var.caf_acr_private_dns_zone_id
  }

  private_service_connection {
    name                           = azurerm_container_registry.caf_azure_container_registry.name
    private_connection_resource_id = azurerm_container_registry.caf_azure_container_registry.id
    is_manual_connection           = var.caf_acr_private_dns_zone_is_manual
    subresource_names              = var.caf_acr_private_dns_zone_subresource_name
  }

  //tags = var.tags
}

//**********************************************************************************************