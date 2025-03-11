## Common Variables
//**********************************************************************************************

variable "environment" {
  type        = string
  description = "(Required) The environment where resources will be deployed into. Part of the naming scheme."
}
variable "location" {
  type        = string
  description = "(Required) The cafoud region where resources will be deployed into."
  default     = "eastus"
}
variable "caf_application" {
  type        = string
  description = "(Required) The name of the application where the resource is being deployed"
  default     = "cbcore"
}
variable "tenant_id" {
  type        = string
  description = "(Required) The tenant ID of the tenant where key vault is being deployed"
  default     = "c09fae9e-0750-4861-a01d-0dd6d9721be7"
}

variable "devnodepool_map" {
  type = map(any)
  default = {
    cbcore = {
      caf_kubernetes_node_pool_name        = "cbcorepool"
      caf_kubernetes_node_pool_max_count   = 20
      caf_kubernetes_node_pool_vm_size     = "Standard_D4ds_v5"
      caf_kubernetes_node_pool_node_taints = ["app-type=cb-core:NoSchedule"]
      kubernetes_version                   = "1.29.0"
    }
    prapps = {
      caf_kubernetes_node_pool_name        = "prappspool"
      caf_kubernetes_node_pool_max_count   = 63
      caf_kubernetes_node_pool_vm_size     = "Standard_D4ds_v5"
      caf_kubernetes_node_pool_node_taints = ["app-type=pr:NoSchedule"]
      kubernetes_version                   = "1.29.0"
    }
    knative = {
      caf_kubernetes_node_pool_name        = "knativepool"
      caf_kubernetes_node_pool_max_count   = 50
      caf_kubernetes_node_pool_vm_size     = "Standard_D4ds_v5"
      caf_kubernetes_node_pool_node_taints = []
      kubernetes_version                   = "1.29.0"
    }
    prapps1 = {
      caf_kubernetes_node_pool_name        = "prappspool1"
      caf_kubernetes_node_pool_max_count   = 25
      caf_kubernetes_node_pool_vm_size     = "Standard_E4as_v4"
      caf_kubernetes_node_pool_node_taints = ["app-type=pr:NoSchedule"]
      kubernetes_version                   = "1.29.0"
    }
    prapps2 = {
      caf_kubernetes_node_pool_name        = "prappspool2"
      caf_kubernetes_node_pool_max_count   = 25
      caf_kubernetes_node_pool_vm_size     = "Standard_D4as_v4"
      caf_kubernetes_node_pool_node_taints = ["app-type=pr:NoSchedule"]
      kubernetes_version                   = "1.29.0"
    }
  }
}
variable "cbcorepool" {
  type = map(any)
  default = {
    cbcore = {
      caf_kubernetes_node_pool_name        = "cbcorepool"
      caf_kubernetes_node_pool_max_count   = 10
      caf_kubernetes_node_pool_vm_size     = "Standard_D4ds_v5"
      caf_kubernetes_node_pool_node_taints = ["app-type=cb-core:NoSchedule"]
      kubernetes_version                   = "1.29.0"
    }
    knative = {
      caf_kubernetes_node_pool_name        = "knativepool"
      caf_kubernetes_node_pool_max_count   = 50
      caf_kubernetes_node_pool_vm_size     = "Standard_D4ds_v5"
      caf_kubernetes_node_pool_node_taints = []
      kubernetes_version                   = "1.29.0"
    }
  }
}

variable "la_sku" {
  description = "Specifies the SKU of the Log Analytics Workspace. Possible values are Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, and PerGB2018 (new SKU as of 2018-04-03). Defaults to PerGB2018"
  default     = "PerGB2018"
}

variable "la_retention" {
  description = "The workspace data retention in days. Possible values range between 30 and 730."
  default     = 30
}
variable "azure_config" {
  type = map(any)
  default = {
    dev = {
      criticality                         = "Medium"
      suffix                              = "001"
      env_prefix                          = "dev"
      core_vnet_address_space             = ["10.10.0.0/16"]
      aks_subnet_address_space            = "10.10.0.0/24"
      pe_subnet_address_space             = "10.10.1.0/24"
      kubernetes_version                  = "1.29.0"
      default_nodepool_kubernetes_version = "1.29.0"
      caf_azure_container_registry_sku    = "Basic"
      caf_redis_cache_sku                 = "Standard"
      caf_redis_cache_family              = "C"
      caf_azure_postgresql_sku            = "B_Standard_B2s"
      caf_azure_postgresql_version        = "16"
      psql_administrator_login            = "cbcoreadmin"
      nodepoolname                        = "cbcorepool"
      zones                               = ["1"]
      cloudamqp_plan                      = "squirrel-1"
      backup_retention_days               = "7"
      sku_tier                            = "Free"
      slack_channel_id                    = "C07GYRJ4ALV"
      cors_allowed_origins                = ["https://*.herokuapp.com", "http://localhost:8000", "https://*.crowdbotics.com"]
    }
    qa = {
      criticality                         = "High"
      suffix                              = "01"
      env_prefix                          = "qa"
      core_vnet_address_space             = ["10.9.0.0/16"]
      aks_subnet_address_space            = "10.9.0.0/24"
      pe_subnet_address_space             = "10.9.1.0/24"
      kubernetes_version                  = "1.29.0"
      default_nodepool_kubernetes_version = "1.29.0"
      caf_azure_container_registry_sku    = "Standard"
      caf_redis_cache_sku                 = "Basic"
      caf_redis_cache_family              = "C"
      caf_azure_postgresql_sku            = "B_Standard_B2s"
      caf_azure_postgresql_version        = "16"
      psql_administrator_login            = "cbcoreadmin"
      nodepoolname                        = "cbcorepool"
      zones                               = ["1"]
      cloudamqp_plan                      = "squirrel-1"
      backup_retention_days               = "7"
      sku_tier                            = "Free"
      slack_channel_id                    = "C07H1NCGZMG"
      cors_allowed_origins                = ["https://*.herokuapp.com", "https://qa-test-hub.crowdbotics.com", "http://localhost:8000"]
    }
    # staging = {
    #   criticality                      = "High"
    #   suffix                           = "01"
    #   env_prefix                       = "stg"
    #   core_vnet_address_space          = ["10.8.0.0/16"]
    #   aks_subnet_address_space         = "10.8.0.0/24"
    #   pe_subnet_address_space          = "10.8.1.0/24"
    #   kubernetes_version               = "1.28.5"
    #   caf_azure_container_registry_sku = "Standard"
    #   caf_redis_cache_sku              = "Basic"
    #   caf_redis_cache_family           = "C"
    #   caf_azure_postgresql_sku         = "B_Standard_B1ms"
    #   caf_azure_postgresql_version     = "16"
    #   psql_administrator_login         = "cbcoreadmin"
    #   nodepoolname                     = "cbcorepool"
    #   zones                            = ["1"]
    #   cloudamqp_plan                   = "tiger"
    #   backup_retention_days            = "7"
    #   sku_tier                         = "Free"
    #   slack_channel_id                 = "C010XGFELDR"
    #   cors_allowed_origins             = ["https://*.herokuapp.com", "https://staging.crowdbotics.com", "http://localhost:8000"]
    # }
    production = {
      criticality                         = "Mission Critical"
      suffix                              = "01"
      env_prefix                          = "prod"
      core_vnet_address_space             = ["10.7.0.0/16"]
      aks_subnet_address_space            = "10.7.0.0/24"
      pe_subnet_address_space             = "10.7.1.0/24"
      kubernetes_version                  = "1.28.5"
      default_nodepool_kubernetes_version = "1.28.5"
      caf_azure_container_registry_sku    = "Premium"
      caf_redis_cache_sku                 = "Premium"
      caf_redis_cache_family              = "P"
      caf_azure_postgresql_sku            = "GP_Standard_D2s_v3"
      caf_azure_postgresql_version        = "16"
      psql_administrator_login            = "cbcoreadmin"
      nodepoolname                        = "cbcorepool"
      zones                               = ["1"]
      cloudamqp_plan                      = "squirrel-1"
      backup_retention_days               = "35"
      sku_tier                            = "Standard"
      slack_channel_id                    = "C010XGFELDR"
      cors_allowed_origins                = ["https://*.herokuapp.com", "https://app.crowdbotics.com", "http://localhost:8000"]
    }
  }

}
