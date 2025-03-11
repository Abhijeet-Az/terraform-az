// Deploy the storage account
//**********************************************************************************************
resource "azurerm_storage_account" "caf_storage_account" {
  name                     = "stg${var.caf_application}${var.env_prefix}${var.suffix}"
  resource_group_name      = var.caf_storage_account_resource_group_name
  location                 = var.location
  account_tier             = var.caf_storage_account_tier
  account_replication_type = var.caf_storage_account_replication_type

  blob_properties {
    dynamic "cors_rule" {
      for_each = var.cors_needed ? var.cors_rule : []
      content {
        max_age_in_seconds = cors_rule.value.max_age_in_seconds
        exposed_headers    = cors_rule.value.exposed_headers
        allowed_headers    = cors_rule.value.allowed_headers
        allowed_methods    = cors_rule.value.allowed_methods
        allowed_origins    = cors_rule.value.allowed_origins
      }
    }
  }
  lifecycle {
    prevent_destroy = true
  }
}
resource "azurerm_storage_container" "storage_containers" {
  for_each              = var.stg_container_map
  name                  = each.value.container_name
  storage_account_name  = azurerm_storage_account.caf_storage_account.name
  container_access_type = "container"
}
// Sets up the private endpoint for  Azure Storage Account - Blob
//**********************************************************************************************
resource "azurerm_private_endpoint" "caf_storage_account_private_endpoint_blob" {
  name                = "pe-stg${var.caf_application}${var.env_prefix}${var.suffix}"
  location            = var.location
  resource_group_name = var.caf_storage_account_resource_group_name
  subnet_id           = var.caf_storage_account_private_endpoint_subnet_id

  private_dns_zone_group {
    name                 = "privatelink.blob.core.windows.net"
    private_dns_zone_ids = var.caf_storage_account_private_dns_zone_ids
  }

  private_service_connection {
    name                           = azurerm_storage_account.caf_storage_account.name
    private_connection_resource_id = azurerm_storage_account.caf_storage_account.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  //tags = var.tags
}
//**********************************************************************************************