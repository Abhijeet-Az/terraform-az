# ### Resource group  ###
# //**********************************************************************************************
module "caf_resource_group" {

  source     = "github.com/crowdbotics/project-deploy//azure/terraform/modules/caf_resource_group"
  env_prefix = var.environment
  location   = var.location
  suffix     = var.suffix
  tags = {
    Criticality     = "Mission Critical"
    ApplicationName = "CB-Shared(ESLZ)"
    Environment     = var.environment
    Owner           = "engineering@crowdbotics.com"
  }
}

module "caf_vnet" {
  source                  = "github.com/crowdbotics/project-deploy//azure/terraform/modules/caf_vnet"
  env_prefix              = var.environment
  location                = var.location
  suffix                  = var.suffix
  caf_application         = var.caf_application
  core_vnet_address_space = var.core_vnet_address_space
  resource_group_name     = module.caf_resource_group.caf_resource_group.name
  caf_vnet_subnet_combined = {
    "pe" = {
      address_prefixes  = [cidrsubnet(var.pe_subnet_address_space, 0, 0)]
      subnet_name       = "snet-pe-shared-eastus-001"
      name              = "pe"
      delegation_needed = false
    }
    "appgw" = {
      address_prefixes  = [cidrsubnet(var.appgw_subnet_address_space, 0, 0)]
      subnet_name       = "snet-appgw-shared-eastus-001"
      name              = "appgw"
      delegation_needed = false
    }
    "appgw_ipv6" = {
      address_prefixes  = [cidrsubnet(var.appgw_ipv6_subnet_address_space, 0, 0), "2001:db8:0:1::/64"]
      subnet_name       = "snet-appgw-shared-eastus-002"
      name              = "appgw_ipv6"
      delegation_needed = false
    }
    "Gateway" = {
      address_prefixes  = [cidrsubnet(var.gateway_subnet_address_space, 0, 0)]
      subnet_name       = "GatewaySubnet"
      name              = "GatewaySubnet"
      delegation_needed = false
    }
    "DNS_Resolver_Inbound" = {
      address_prefixes  = [cidrsubnet(var.dns_subnet_address_space, 0, 0)]
      subnet_name       = "ssnet-resolver-inbound-shared-eastus-001"
      name              = "DNS_Resolver_Inbound"
      delegation_needed = true
      delegation = {
        name                       = "Microsoft.Network.dnsResolvers"
        delegation_name            = "Microsoft.Network/dnsResolvers"
        delegation_allowed_actions = "Microsoft.Network/virtualNetworks/subnets/join/action"
      }
    }
  }
  sharedvnetpeermap = {
    dev = {
      name                      = "dev"
      suffix                    = "001"
      remote_virtual_network_id = data.terraform_remote_state.dev.outputs.caf_vnet_id
    },
    qa = {
      name                      = "qa"
      suffix                    = "01"
      remote_virtual_network_id = data.terraform_remote_state.qa.outputs.caf_vnet_id
    },
    # stg = {
    #   name                      = "stg"
    #   suffix                    = "01"
    #   remote_virtual_network_id = data.terraform_remote_state.staging.outputs.caf_vnet_id
    # },
    prod = {
      name                      = "prod"
      suffix                    = "01"
      remote_virtual_network_id = data.terraform_remote_state.production.outputs.caf_vnet_id
    }
  }
  depends_on = [module.caf_resource_group]
}

module "caf_azure_keyvault" {

  source                          = "github.com/crowdbotics/project-deploy//azure/terraform/modules/caf_keyvault"
  env_prefix                      = var.environment
  location                        = var.location
  suffix                          = var.suffix
  caf_application                 = var.caf_application
  caf_keyvault_rg_name            = module.caf_resource_group.caf_resource_group.name
  tenant_id                       = var.tenant_id
  azurekeyvault_subnet_id         = module.caf_vnet.caf_vnet_subnet["pe"].id
  diag_log_analytics_workspace_id = azurerm_log_analytics_workspace.la_workspace.id
  depends_on                      = [module.caf_resource_group, module.caf_vnet]
}

module "caf_azure_private_dns_resolver" {

  source                          = "github.com/crowdbotics/project-deploy//azure/terraform/modules/caf_azure_private_dns_resolver"
  env_prefix                      = var.environment
  location                        = var.location
  suffix                          = var.suffix
  caf_application                 = var.caf_application
  dns_resolver_rg_name            = module.caf_resource_group.caf_resource_group.name
  dns_resolver_vnet_id            = module.caf_vnet.core_vnet.id
  dns_resolver_inbound_subnet_id  = module.caf_vnet.caf_vnet_subnet["DNS_Resolver_Inbound"].id
  dns_resolver_inbound_ip_address = "10.6.2.4"
  depends_on                      = [module.caf_resource_group, module.caf_vnet]
}

module "caf_azure_public_ip" {
  source          = "github.com/crowdbotics/project-deploy//azure/terraform/modules/caf_public_ip_address"
  env_prefix      = var.environment
  location        = var.location
  suffix          = var.suffix
  caf_application = var.caf_application
  public_ip_map   = var.public_ip_map
  pip_rg_name     = module.caf_resource_group.caf_resource_group.name

  depends_on = [module.caf_resource_group, module.caf_vnet]
}


module "caf_azure_private_dns_zone" {
  source               = "github.com/crowdbotics/project-deploy//azure/terraform/modules/caf_azure_private_dns_zone"
  dns_zone_rg_name     = module.caf_resource_group.caf_resource_group.name
  private_dns_zone_map = var.private_dns_zone_map
  depends_on           = [module.caf_resource_group, module.caf_vnet]
}

module "caf_azure_application_gateway" {
  source                    = "github.com/crowdbotics/project-deploy//azure/terraform/modules/caf_azure_application_gateway"
  env_prefix                = var.environment
  location                  = var.location
  suffix                    = var.suffix
  appgw_rg_name             = module.caf_resource_group.caf_resource_group.name
  appgw_subnet_id           = module.caf_vnet.caf_vnet_subnet["appgw"].id
  frontend_port_map         = var.frontend_port_map
  appgw_public_ip_id        = module.caf_azure_public_ip.caf_azure_public_ip["appgw"].id
  backend_address_pool_map  = local.backend_address_pool_map
  ssl_certificate_password  = var.ssl_certificate_password
  probe_map                 = local.probe_map
  backend_http_settings_map = local.backend_http_settings_map
  http_listener_map         = local.http_listener_map
  routing_rule_map          = local.routing_rule_map
  depends_on                = [module.caf_resource_group, module.caf_vnet]
}

module "caf_azure_virtual_network_gateway" {
  source        = "github.com/crowdbotics/project-deploy//azure/terraform/modules/caf_azure_virtual_network_gateway"
  env_prefix    = var.environment
  location      = var.location
  suffix        = var.suffix
  vgw_sku       = var.vgw_sku
  vgw_pip_id    = module.caf_azure_public_ip.caf_azure_public_ip["vgw"].id
  vgw_rg_name   = module.caf_resource_group.caf_resource_group.name
  vgw_subnet_id = module.caf_vnet.caf_vnet_subnet["Gateway"].id
  depends_on    = [module.caf_resource_group, module.caf_vnet]
}

module "caf_azure_local_network_gateway" {
  source                    = "github.com/crowdbotics/project-deploy//azure/terraform/modules/caf_azure_local_network_gateway"
  location                  = var.location
  suffix                    = var.suffix
  lgw_rg_name               = module.caf_resource_group.caf_resource_group.name
  local_network_gateway_map = var.local_network_gateway_map
  depends_on                = [module.caf_resource_group, module.caf_vnet, module.caf_azure_virtual_network_gateway]
}

module "keyvault_secret" {
  source                   = "github.com/crowdbotics/project-deploy//azure/terraform/modules/caf_azure_key_vault_secret"
  caf_key_vault_secret_map = var.caf_key_vault_secret_map
  key_vault_id             = module.caf_azure_keyvault.caf_keyvault.id
}

module "caf_azure_s2s_connection" {
  source       = "github.com/crowdbotics/project-deploy//azure/terraform/modules/caf_azure_vnet_gateway_connection"
  location     = var.location
  conn_rg_name = module.caf_resource_group.caf_resource_group.name
  gateway_connection_map = {
    aws01 = {
      connection_name            = "conn-aws-shared-001"
      virtual_network_gateway_id = module.caf_azure_virtual_network_gateway.azurerm_virtual_network_gateway.id
      local_network_gateway_id   = module.caf_azure_local_network_gateway.azurerm_local_network_gateway["aws01"].id
      shared_key                 = module.keyvault_secret.caf_keyvault_secret["01"].value
      connection_type            = "IPsec"
      connection_protocol        = "IKEv2"
    },
    aws02 = {
      connection_name            = "conn-aws-shared-002"
      virtual_network_gateway_id = module.caf_azure_virtual_network_gateway.azurerm_virtual_network_gateway.id
      local_network_gateway_id   = module.caf_azure_local_network_gateway.azurerm_local_network_gateway["aws02"].id
      shared_key                 = module.keyvault_secret.caf_keyvault_secret["02"].value
      connection_type            = "IPsec"
      connection_protocol        = "IKEv2"
    }
  }
  depends_on = [module.caf_resource_group, module.caf_vnet, module.caf_azure_virtual_network_gateway, module.caf_azure_local_network_gateway]
}

module "caf_azure_application_gateway_ipv6" {
  source                    = "github.com/crowdbotics/project-deploy//azure/terraform/modules/caf_azure_application_gateway_ipv6"
  env_prefix                = var.environment
  location                  = var.location
  suffix                    = var.suffix
  appgw_rg_name             = module.caf_resource_group.caf_resource_group.name
  appgw_subnet_id           = module.caf_vnet.caf_vnet_subnet["appgw_ipv6"].id
  frontend_port_map         = var.frontend_port_map
  frontend_ip_map           = local.frontend_ip_map
  backend_address_pool_map  = local.backend_address_pool_map_ipv6
  ssl_certificate_password  = var.ssl_certificate_password
  probe_map                 = local.probe_map_ipv6
  backend_http_settings_map = local.backend_http_settings_map_ipv6
  http_listener_map         = local.http_listener_map_ipv6
  routing_rule_map          = local.routing_rule_map_ipv6
  depends_on                = [module.caf_resource_group, module.caf_vnet]
}