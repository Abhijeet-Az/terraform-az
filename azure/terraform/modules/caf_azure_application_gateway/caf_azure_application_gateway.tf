resource "azurerm_application_gateway" "application_gateway" {
  name                = "appgw-${var.env_prefix}-${var.location}-${var.suffix}"
  resource_group_name = var.appgw_rg_name
  location            = var.location
  zones               = ["2"]
  enable_http2        = true

  sku {
    name     = var.appgw_sku
    tier     = var.appgw_tier
    capacity = 0
  }

  autoscale_configuration {
    max_capacity = var.appgw_max_capacity
    min_capacity = var.appgw_min_capacity
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = var.appgw_subnet_id
  }

  dynamic "frontend_port" {
    for_each = var.frontend_port_map
    content {
      name = frontend_port.value.frontend_port_name
      port = frontend_port.value.port
    }
  }

  frontend_ip_configuration {
    name                 = "appGwPublicFrontendIpIPv4"
    public_ip_address_id = var.appgw_public_ip_id
  }

  dynamic "backend_address_pool" {
    for_each = var.backend_address_pool_map
    content {
      name         = backend_address_pool.value.backend_address_pool_name
      ip_addresses = backend_address_pool.value.backend_address_pool_ip_address
    }
  }

  trusted_root_certificate {
    name = "Cloudflare"
    data = filebase64("${path.module}/certificate.cer")
  }

  ssl_certificate {
    data     = filebase64("${path.module}/server-cb.pfx")
    name     = "c-wildcard"
    password = var.ssl_certificate_password
  }

  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings_map
    content {
      name                                = backend_http_settings.value.name
      cookie_based_affinity               = "Disabled"
      path                                = ""
      port                                = 443
      protocol                            = "Https"
      request_timeout                     = 360
      pick_host_name_from_backend_address = false
      host_name                           = backend_http_settings.value.host_name
      trusted_root_certificate_names      = ["Cloudflare"]
    }
  }

  dynamic "http_listener" {
    for_each = var.http_listener_map
    content {
      name                           = http_listener.value.http_listener_name
      frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
      frontend_port_name             = http_listener.value.frontend_port_name
      protocol                       = http_listener.value.protocol
      host_names                     = http_listener.value.host_names
      ssl_certificate_name           = "c-wildcard"
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.routing_rule_map
    content {
      name                       = request_routing_rule.value.routing_rule_name
      priority                   = request_routing_rule.value.priority
      rule_type                  = "Basic"
      http_listener_name         = request_routing_rule.value.listener_name
      backend_address_pool_name  = request_routing_rule.value.backend_address_pool_name
      backend_http_settings_name = request_routing_rule.value.http_setting_name
    }
  }

  dynamic "probe" {
    for_each = var.probe_map
    content {
      interval                                  = 30
      minimum_servers                           = 0
      name                                      = probe.value.probe_name
      path                                      = probe.value.probe_path
      pick_host_name_from_backend_http_settings = probe.value.probe_map_bool
      protocol                                  = "Https"
      timeout                                   = 30
      unhealthy_threshold                       = 3
      match {
        status_code = ["200-399"]
      }
    }
  }
  lifecycle {
    prevent_destroy = true
  }
}