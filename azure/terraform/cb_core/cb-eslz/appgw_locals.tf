locals {
  frontend_ip_map = {
    ipv4 = {
      name                 = "appgw-frontend-ipv4"
      public_ip_address_id = module.caf_azure_public_ip.caf_azure_public_ip["appgw_ipv4"].id
    }
    ipv6 = {
      name                 = "appgw-frontend-ipv6"
      public_ip_address_id = module.caf_azure_public_ip.caf_azure_public_ip["appgw_ipv6"].id
    }
  }
  backend_address_pool_map_ipv6 = {
    dev = {
      backend_address_pool_name       = "${local.backend_address_pool_map_key}-dev"
      backend_address_pool_ip_address = ["10.10.0.254"]
    }
  }
  probe_map_ipv6 = {
    dev = {
      probe_name     = "dev"
      probe_path     = local.default_probe_path
      probe_map_bool = local.default_probe_bool
    }
  }
  backend_http_settings_map_ipv6 = {
    dev = {
      name      = "${local.backend_http_settings_key}-dev"
      host_name = "crowdbotics-slack-dev.crowdbotics.com"
    }
  }
  http_listener_map_ipv6 = {
    dev_ipv4 = {
      http_listener_name             = "${local.http_listener_map_key}-dev-ipv4-${local.http_listener_protocol}"
      frontend_port_name             = local.http_listener_frontend_port_name
      frontend_ip_configuration_name = local.frontend_ip_map["ipv4"].name
      protocol                       = local.http_listener_protocol
      host_names                     = ["azure-dev.crowdbotics.com", "crowdbotics-slack-dev.crowdbotics.com"]
    },
    dev_ipv6 = {
      http_listener_name             = "${local.http_listener_map_key}-dev-ipv6-${local.http_listener_protocol}"
      frontend_port_name             = local.http_listener_frontend_port_name
      frontend_ip_configuration_name = local.frontend_ip_map["ipv6"].name
      protocol                       = local.http_listener_protocol
      host_names                     = ["azure-dev.crowdbotics.com", "crowdbotics-slack-dev.crowdbotics.com"]
    }
  }
  routing_rule_map_ipv6 = {
    dev_ipv4 = {
      routing_rule_name         = "${local.routing_rule_map_key}-dev-ipv4-${local.http_listener_protocol}"
      listener_name             = "${local.http_listener_map_key}-dev-ipv4-${local.http_listener_protocol}"
      priority                  = "2"
      backend_address_pool_name = "be-cb-${local.http_listener_map_key}-dev"
      http_setting_name         = "${local.backend_http_settings_key}-dev"
    }
    dev_ipv6 = {
      routing_rule_name         = "${local.routing_rule_map_key}-dev-ipv6-${local.http_listener_protocol}"
      listener_name             = "${local.http_listener_map_key}-dev-ipv6-${local.http_listener_protocol}"
      priority                  = "3"
      backend_address_pool_name = "be-cb-${local.http_listener_map_key}-dev"
      http_setting_name         = "${local.backend_http_settings_key}-dev"
    }
  }
}