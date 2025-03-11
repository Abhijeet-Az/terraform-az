// Sets up an instance of Azure PostGres SQL
//**********************************************************************************************
resource "azurerm_postgresql_flexible_server" "caf_azure_postgresql_server_replica" {
  name                = "psql-${var.env_prefix}-${var.caf_application}-replica-${var.suffix}"
  resource_group_name = var.caf_azure_postgresql_rg_name
  location            = var.location
  sku_name            = var.caf_azure_postgresql_sku
  version             = var.caf_azure_postgresql_version
  zone                = "3"
  storage_mb          = 131072
  auto_grow_enabled   = true
  create_mode         = "Replica"
  source_server_id    = var.azure_psql_replica_source_server_id
  authentication {
    password_auth_enabled = true
  }
  //tags                          = var.tags
  administrator_login    = var.psql_administrator_login
  administrator_password = var.psql_administrator_password
  timeouts {
    create = local.timeout_duration
    delete = local.timeout_duration
  }
  lifecycle {
    prevent_destroy = true
  }

}
//**********************************************************************************************
resource "azurerm_private_endpoint" "caf_psql_private_endpoint" {
  name                = "pe-psql-${var.env_prefix}-${var.caf_application}-replica-${var.suffix}"
  location            = var.location
  resource_group_name = var.caf_azure_postgresql_rg_name
  subnet_id           = var.azure_psql_subnet_id

  private_dns_zone_group {
    name                 = "privatelink.postgres.database.azure.com"
    private_dns_zone_ids = var.caf_psql_private_dns_zone_id
  }

  private_service_connection {
    name                           = azurerm_postgresql_flexible_server.caf_azure_postgresql_server_replica.name
    private_connection_resource_id = azurerm_postgresql_flexible_server.caf_azure_postgresql_server_replica.id
    is_manual_connection           = var.caf_psql_private_dns_zone_is_manual
    subresource_names              = var.caf_psql_private_dns_zone_subresource_name
  }
  //tags = var.tags
}

//**********************************************************************************************