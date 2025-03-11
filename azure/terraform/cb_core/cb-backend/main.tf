# ### Resource group  ###
# //**********************************************************************************************
module "caf_resource_group" {
  source     = "github.com/crowdbotics/project-deploy//azure/terraform/modules/caf_resource_group"
  env_prefix = var.azure_config[var.environment].env_prefix
  location   = var.location
  suffix     = var.azure_config[var.environment].suffix
  tags = {
    Criticality     = var.azure_config[var.environment].criticality
    ApplicationName = "CB-Core"
    Environment     = var.environment
    Owner           = "engineering@crowdbotics.com"
  }
}

module "caf_vnet" {
  source                  = "github.com/crowdbotics/project-deploy//azure/terraform/modules/caf_vnet_spoke"
  env_prefix              = var.azure_config[var.environment].env_prefix
  location                = var.location
  suffix                  = var.azure_config[var.environment].suffix
  caf_application         = var.caf_application
  core_vnet_address_space = var.azure_config[var.environment].core_vnet_address_space
  resource_group_name     = module.caf_resource_group.caf_resource_group.name
  caf_vnet_subnet_combined = {
    "aks" = {
      address_prefixes = [cidrsubnet(var.azure_config[var.environment].aks_subnet_address_space, 0, 0)]
      caf_vnet_purpose = "aks"
    }
    "pe" = {
      address_prefixes = [cidrsubnet(var.azure_config[var.environment].pe_subnet_address_space, 0, 0)]
      caf_vnet_purpose = "pe"
    }
  }
  depends_on = [module.caf_resource_group]
}

module "caf_azure_container_registry" {
  source                               = "github.com/crowdbotics/project-deploy//azure/terraform/modules/caf_azure_container_registry"
  env_prefix                           = var.azure_config[var.environment].env_prefix
  location                             = var.location
  suffix                               = var.azure_config[var.environment].suffix
  caf_application                      = var.caf_application
  caf_azure_container_registry_rg_name = module.caf_resource_group.caf_resource_group.name
  caf_azure_container_registry_sku     = var.azure_config[var.environment].caf_azure_container_registry_sku
  azurecontainerregistry_subnet_id     = module.caf_vnet.caf_vnet_subnet["pe"].id
  depends_on                           = [module.caf_resource_group, module.caf_vnet]
}

module "caf_kubernetes_cluster" {
  source                              = "github.com/crowdbotics/project-deploy//azure/terraform/modules/caf_azure_kubernetes_service"
  env_prefix                          = var.azure_config[var.environment].env_prefix
  location                            = var.location
  suffix                              = var.azure_config[var.environment].suffix
  caf_application                     = var.caf_application
  sku_tier                            = var.azure_config[var.environment].sku_tier
  kubernetes_version                  = var.azure_config[var.environment].kubernetes_version
  caf_aks_rg                          = module.caf_resource_group.caf_resource_group.name
  agent_pool_subnet_id                = module.caf_vnet.caf_vnet_subnet["aks"].id
  oms_workspace_id                    = azurerm_log_analytics_workspace.la_workspace.id
  depends_on                          = [module.caf_resource_group, module.caf_vnet, module.caf_azure_container_registry]
  azurerm_container_registry_id       = module.caf_azure_container_registry.caf_azure_container_registry.id
  prometheus_am_workspace_id          = azurerm_monitor_workspace.am_workspace.id
  action_group_id                     = azurerm_monitor_action_group.action_group.id
  default_nodepool_kubernetes_version = var.azure_config[var.environment].default_nodepool_kubernetes_version
  cluster_level_prometheus_rules      = local.cluster_level_prometheus_rules
  node_level_prometheus_rules         = local.node_level_prometheus_rules
  pod_level_prometheus_rules          = local.pod_level_prometheus_rules
}

module "caf_kubernetes_cluster_node_pools" {
  source                                         = "github.com/crowdbotics/project-deploy//azure/terraform/modules/caf_azure_kubernetes_service_node_pool"
  for_each                                       = var.environment == "dev" ? var.devnodepool_map : var.cbcorepool
  caf_kubernetes_node_pool_name                  = each.value.caf_kubernetes_node_pool_name
  caf_kubernetes_node_pool_max_count             = each.value.caf_kubernetes_node_pool_max_count
  caf_kubernetes_node_pool_orchestrator_version  = each.value.kubernetes_version
  caf_kubernetes_node_pool_node_taints           = each.value.caf_kubernetes_node_pool_node_taints
  location                                       = var.location
  caf_application                                = var.caf_application
  caf_kubernetes_node_pool_kubernetes_cluster_id = module.caf_kubernetes_cluster.caf_kubernetes.id
  caf_kubernetes_node_pool_vm_size               = each.value.caf_kubernetes_node_pool_vm_size
  caf_kubernetes_node_pool_availability_zones    = var.azure_config[var.environment].zones
  caf_kubernetes_node_pool_vnet_subnet_id        = module.caf_vnet.caf_vnet_subnet["aks"].id
  depends_on                                     = [module.caf_resource_group, module.caf_vnet, module.caf_azure_container_registry, module.caf_kubernetes_cluster]
}

module "caf_azure_storage" {
  source                                         = "github.com/crowdbotics/project-deploy//azure/terraform/modules/caf_storage_account"
  env_prefix                                     = var.azure_config[var.environment].env_prefix
  location                                       = var.location
  suffix                                         = var.azure_config[var.environment].suffix
  caf_application                                = var.caf_application
  caf_storage_account_resource_group_name        = module.caf_resource_group.caf_resource_group.name
  caf_storage_account_private_endpoint_subnet_id = module.caf_vnet.caf_vnet_subnet["pe"].id
  cors_needed                                    = true
  cors_rule                                      = local.origin_url_map
  stg_container_map = {
    "cb-dash" = {
      container_name = "cb-dash-${var.azure_config[var.environment].env_prefix}"
    }
    "crowdbotics-slack" = {
      container_name = "crowdbotics-slack-${var.azure_config[var.environment].env_prefix}"
    }
  }
  depends_on = [module.caf_resource_group, module.caf_vnet]
}

module "caf_azure_keyvault" {
  source                          = "github.com/crowdbotics/project-deploy//azure/terraform/modules/caf_keyvault"
  env_prefix                      = var.azure_config[var.environment].env_prefix
  location                        = var.location
  suffix                          = var.azure_config[var.environment].suffix
  caf_application                 = var.caf_application
  caf_keyvault_rg_name            = module.caf_resource_group.caf_resource_group.name
  tenant_id                       = var.tenant_id
  azurekeyvault_subnet_id         = module.caf_vnet.caf_vnet_subnet["pe"].id
  diag_log_analytics_workspace_id = data.terraform_remote_state.shared.outputs.caf_la_workspace.id
  depends_on                      = [module.caf_resource_group, module.caf_vnet]
}



module "caf_azure_redis_cache" {

  source                                     = "github.com/crowdbotics/project-deploy//azure/terraform/modules/caf_redis_cache"
  env_prefix                                 = var.azure_config[var.environment].env_prefix
  location                                   = var.location
  suffix                                     = var.azure_config[var.environment].suffix
  caf_application                            = var.caf_application
  caf_redis_cache_rg_name                    = module.caf_resource_group.caf_resource_group.name
  caf_redis_cache_sku                        = var.azure_config[var.environment].caf_redis_cache_sku
  caf_redis_cache_private_endpoint_subnet_id = module.caf_vnet.caf_vnet_subnet["pe"].id
  caf_redis_cache_family                     = var.azure_config[var.environment].caf_redis_cache_family
  depends_on                                 = [module.caf_resource_group, module.caf_vnet]
}

module "caf_azure_postgresql" {
  source                       = "github.com/crowdbotics/project-deploy//azure/terraform/modules/caf_azure_postgres_db"
  env_prefix                   = var.azure_config[var.environment].env_prefix
  location                     = var.location
  suffix                       = var.azure_config[var.environment].suffix
  caf_application              = var.caf_application
  backup_retention_days        = var.azure_config[var.environment].backup_retention_days
  caf_azure_postgresql_rg_name = module.caf_resource_group.caf_resource_group.name
  caf_azure_postgresql_sku     = var.azure_config[var.environment].caf_azure_postgresql_sku
  caf_azure_postgresql_version = var.azure_config[var.environment].caf_azure_postgresql_version
  psql_administrator_login     = var.azure_config[var.environment].psql_administrator_login
  psql_administrator_password  = data.azurerm_key_vault_secret.psql_admin_pwd.value
  azure_psql_subnet_id         = module.caf_vnet.caf_vnet_subnet["pe"].id
  depends_on                   = [module.caf_resource_group, module.caf_vnet]
}

module "caf_azure_postgresql_replica" {
  count                               = var.environment == "production" ? 1 : 0
  source                              = "github.com/crowdbotics/project-deploy//azure/terraform/modules/caf_azure_postgres_db_replica"
  env_prefix                          = var.azure_config[var.environment].env_prefix
  location                            = var.location
  suffix                              = var.azure_config[var.environment].suffix
  caf_application                     = var.caf_application
  azure_psql_replica_source_server_id = module.caf_azure_postgresql.caf_azure_postgresql_server.id
  caf_azure_postgresql_rg_name        = module.caf_resource_group.caf_resource_group.name
  caf_azure_postgresql_sku            = var.azure_config[var.environment].caf_azure_postgresql_sku
  caf_azure_postgresql_version        = var.azure_config[var.environment].caf_azure_postgresql_version
  psql_administrator_login            = var.azure_config[var.environment].psql_administrator_login
  psql_administrator_password         = data.azurerm_key_vault_secret.psql_admin_pwd.value
  azure_psql_subnet_id                = module.caf_vnet.caf_vnet_subnet["pe"].id
  depends_on                          = [module.caf_resource_group, module.caf_vnet]
}
