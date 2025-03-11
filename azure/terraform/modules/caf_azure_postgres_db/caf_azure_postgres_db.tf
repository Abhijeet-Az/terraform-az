// Sets up an instance of Azure PostGres SQL
//**********************************************************************************************
resource "azurerm_postgresql_flexible_server" "caf_azure_postgresql_server" {
  name                  = "psql-${var.env_prefix}-${var.caf_application}-${var.suffix}"
  resource_group_name   = var.caf_azure_postgresql_rg_name
  location              = var.location
  sku_name              = var.caf_azure_postgresql_sku
  version               = var.caf_azure_postgresql_version
  zone                  = "3"
  storage_mb            = 131072
  auto_grow_enabled     = true
  create_mode           = "Default"
  backup_retention_days = var.backup_retention_days
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
    ignore_changes = [
      name, create_mode, public_network_access_enabled, zone
    ]
    prevent_destroy = true
  }

}
//**********************************************************************************************
resource "azurerm_private_endpoint" "caf_psql_private_endpoint" {
  name                = "pe-psql-${var.caf_application}-${var.env_prefix}-${var.suffix}"
  location            = var.location
  resource_group_name = var.caf_azure_postgresql_rg_name
  subnet_id           = var.azure_psql_subnet_id

  private_dns_zone_group {
    name                 = "privatelink.postgres.database.azure.com"
    private_dns_zone_ids = var.caf_psql_private_dns_zone_id
  }

  private_service_connection {
    name                           = azurerm_postgresql_flexible_server.caf_azure_postgresql_server.name
    private_connection_resource_id = azurerm_postgresql_flexible_server.caf_azure_postgresql_server.id
    is_manual_connection           = var.caf_psql_private_dns_zone_is_manual
    subresource_names              = var.caf_psql_private_dns_zone_subresource_name
  }
  lifecycle {
    ignore_changes = [
      name, private_service_connection
    ]
  }
  //tags = var.tags
}

//**********************************************************************************************