locals {
  slack_webhook_kv_secret_name     = "slackwebhookurl"
  slack_webhook_quota_updates_name = "slackwebhookquotaupdates"
  policyids                        = csvdecode(file("Policies.csv"))
  azure_ad_default_group_owner     = ["fd892370-2cae-40e3-b110-d286e9b00825"] #engineering@crowdbotics.com
  backend_http_settings_key        = "be-slackapp"
  backend_http_settings_map = {
    dev = {
      name      = "${local.backend_http_settings_key}-dev"
      host_name = "crowdbotics-slack-dev.crowdbotics.com"
    },
    qa = {
      name      = "${local.backend_http_settings_key}-qa"
      host_name = "qa-test-hub.crowdbotics.com"
    },
    stg = {
      name      = "${local.backend_http_settings_key}-stg"
      host_name = "stg-internal.crowdbotics.com"
    },
    prod = {
      name      = "${local.backend_http_settings_key}-prod"
      host_name = "app.crowdbotics.com"
    }
  }
  default_probe_path = "/api/v1/app-types"
  default_probe_bool = true
  probe_map = {
    dev = {
      probe_name     = "dev"
      probe_path     = local.default_probe_path
      probe_map_bool = local.default_probe_bool
    },
    qa = {
      probe_name     = "qa"
      probe_path     = local.default_probe_path
      probe_map_bool = local.default_probe_bool
    },
    stg = {
      probe_name     = "stg"
      probe_path     = local.default_probe_path
      probe_map_bool = local.default_probe_bool
    },
    prod = {
      probe_name     = "prod"
      probe_path     = local.default_probe_path
      probe_map_bool = local.default_probe_bool
    }
  }

  http_listener_map_key            = "slackapp"
  http_listener_frontend_port_name = "port_443"
  http_listener_protocol           = "Https"
  http_listener_map = {
    dev = {
      http_listener_name = "${local.http_listener_map_key}-dev-${local.http_listener_protocol}"
      frontend_port_name = local.http_listener_frontend_port_name
      protocol           = local.http_listener_protocol
      host_names         = ["azure-dev.crowdbotics.com", "crowdbotics-slack-dev.crowdbotics.com"]
    },
    qa = {
      http_listener_name = "${local.http_listener_map_key}-qa-${local.http_listener_protocol}"
      frontend_port_name = local.http_listener_frontend_port_name
      protocol           = local.http_listener_protocol
      host_names         = ["azure-qa.crowdbotics.com", "qa-test-hub.crowdbotics.com"]
    },
    stg = {
      http_listener_name = "${local.http_listener_map_key}-stg-${local.http_listener_protocol}"
      frontend_port_name = local.http_listener_frontend_port_name
      protocol           = local.http_listener_protocol
      host_names         = ["azure-stg.crowdbotics.com", "staging.crowdbotics.com"]
    },
    prod = {
      http_listener_name = "${local.http_listener_map_key}-prod-${local.http_listener_protocol}"
      frontend_port_name = local.http_listener_frontend_port_name
      protocol           = local.http_listener_protocol
      host_names         = ["azure-prod.crowdbotics.com", "app.crowdbotics.com"]
    }
  }
  backend_address_pool_map_key = "be-cb-slackapp"
  backend_address_pool_map = {
    dev = {
      backend_address_pool_name       = "${local.backend_address_pool_map_key}-dev"
      backend_address_pool_ip_address = ["10.10.0.254"]
    },
    qa = {
      backend_address_pool_name       = "${local.backend_address_pool_map_key}-qa"
      backend_address_pool_ip_address = ["10.9.0.254"]
    },
    stg = {
      backend_address_pool_name       = "${local.backend_address_pool_map_key}-stg"
      backend_address_pool_ip_address = ["10.8.0.254"]
    },
    prod = {
      backend_address_pool_name       = "${local.backend_address_pool_map_key}-prod"
      backend_address_pool_ip_address = ["10.7.0.254"]
    }
  }
  routing_rule_map_key = "rr-cb-${local.http_listener_map_key}"
  routing_rule_map = {
    dev = {
      routing_rule_name         = "${local.routing_rule_map_key}-dev-${local.http_listener_protocol}"
      listener_name             = "${local.http_listener_map_key}-dev-${local.http_listener_protocol}"
      priority                  = "2"
      backend_address_pool_name = "be-cb-${local.http_listener_map_key}-dev"
      http_setting_name         = "${local.backend_http_settings_key}-dev"
    },
    qa = {
      routing_rule_name         = "${local.routing_rule_map_key}-qa-${local.http_listener_protocol}"
      listener_name             = "${local.http_listener_map_key}-qa-${local.http_listener_protocol}"
      priority                  = "21"
      backend_address_pool_name = "be-cb-${local.http_listener_map_key}-qa"
      http_setting_name         = "${local.backend_http_settings_key}-qa"
    },
    stg = {
      routing_rule_name         = "${local.routing_rule_map_key}-stg-${local.http_listener_protocol}"
      listener_name             = "${local.http_listener_map_key}-stg-${local.http_listener_protocol}"
      priority                  = "3"
      backend_address_pool_name = "be-cb-${local.http_listener_map_key}-stg"
      http_setting_name         = "${local.backend_http_settings_key}-stg"
    },
    prod = {
      routing_rule_name         = "${local.routing_rule_map_key}-prod-${local.http_listener_protocol}"
      listener_name             = "${local.http_listener_map_key}-prod-${local.http_listener_protocol}"
      priority                  = "4"
      backend_address_pool_name = "be-cb-${local.http_listener_map_key}-prod"
      http_setting_name         = "${local.backend_http_settings_key}-prod"
    }
  }
}