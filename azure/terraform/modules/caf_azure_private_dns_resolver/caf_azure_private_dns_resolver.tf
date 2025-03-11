resource "azurerm_private_dns_resolver" "dns_resolver" {
  name                = "resolver-${var.env_prefix}-${var.location}-${var.suffix}"
  resource_group_name = var.dns_resolver_rg_name
  location            = var.location
  virtual_network_id  = var.dns_resolver_vnet_id
  lifecycle {
    prevent_destroy = true
  }
  timeouts {
    create = local.timeout_duration
    delete = local.timeout_duration
  }
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "dns_resolver_inbound" {
  name                    = "resolver-inbound-${var.env_prefix}-${var.location}-${var.suffix}"
  private_dns_resolver_id = azurerm_private_dns_resolver.dns_resolver.id
  location                = azurerm_private_dns_resolver.dns_resolver.location
  ip_configurations {
    private_ip_allocation_method = "Static"
    subnet_id                    = var.dns_resolver_inbound_subnet_id
    private_ip_address           = var.dns_resolver_inbound_ip_address
  }
  timeouts {
    create = local.timeout_duration
    delete = local.timeout_duration
  }
}