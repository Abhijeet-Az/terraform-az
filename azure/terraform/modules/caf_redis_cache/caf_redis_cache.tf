// Sets up for Azure Redis Cache
//**********************************************************************************************
resource "azurerm_redis_cache" "caf_redis_cache" {
  resource_group_name           = var.caf_redis_cache_rg_name
  name                          = "redis-${var.caf_application}-${var.env_prefix}-${var.suffix}"
  location                      = var.location
  sku_name                      = var.caf_redis_cache_sku
  capacity                      = var.caf_redis_cache_sku == "Premium" ? var.caf_redis_cache_capacity : 0
  family                        = var.caf_redis_cache_family
  non_ssl_port_enabled          = var.caf_redis_cache_non_ssl_enabled
  public_network_access_enabled = var.caf_redis_cache_public_network_access_enabled
  minimum_tls_version           = var.caf_redis_cache_minimum_tls_version

  dynamic "identity" {
    for_each = var.caf_redis_cache_identity_type != null ? [1] : []
    content {
      type         = var.caf_redis_cache_identity_type
      identity_ids = var.caf_redis_cache_identity_type != "SystemAssigned" ? var.caf_redis_cache_identity_ids : null
    }
  }
  lifecycle {
    ignore_changes = [
      public_network_access_enabled
    ]
    prevent_destroy = true
  }

  //tags = var.tags
}

// Sets up the private endpoint for  Azure Redis Cache
//**********************************************************************************************
resource "azurerm_private_endpoint" "caf_redis_cache_private_endpoint_redis_cache" {
  name                = "pe-redis-${var.caf_application}-${var.env_prefix}-${var.suffix}"
  location            = var.location
  resource_group_name = var.caf_redis_cache_rg_name
  subnet_id           = var.caf_redis_cache_private_endpoint_subnet_id

  private_dns_zone_group {
    name                 = var.caf_redis_cache_private_dns_zone_name
    private_dns_zone_ids = var.caf_redis_cache_private_dns_zone_ids
  }

  private_service_connection {
    name                           = azurerm_redis_cache.caf_redis_cache.name
    private_connection_resource_id = azurerm_redis_cache.caf_redis_cache.id
    is_manual_connection           = false
    subresource_names              = ["redisCache"]
  }

  //tags = var.tags
}
//**********************************************************************************************