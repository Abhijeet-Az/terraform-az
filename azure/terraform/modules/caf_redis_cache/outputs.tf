// Outputs Azure Service Bus
//**********************************************************************************************
output "caf_redis_cache" {
  description = "Azure Redis Cache output"
  value       = azurerm_redis_cache.caf_redis_cache
}
output "azurerm_private_endpoint" {
  value = azurerm_private_endpoint.caf_redis_cache_private_endpoint_redis_cache.id
}
//**********************************************************************************************