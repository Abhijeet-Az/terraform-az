## Common Variables
//**********************************************************************************************

variable "environment" {
  type        = string
  description = "(Required) The environment where resources will be deployed into. Part of the naming scheme."
  default     = "shared"
}

variable "location" {
  type        = string
  description = "(Required) The cafoud region where resources will be deployed into."
  default     = "eastus"
}

variable "suffix" {
  type        = string
  description = "(Required) The instance count where the resource is being deployed ex- 001,002"
  default     = "001"
}
variable "caf_application" {
  type        = string
  description = "(Required) The name of the application where the resource is being deployed"
  default     = "cb"
}

###Vnet Variable
//***********************************************************************************************

// Required Variables Azure Virtual network
//**********************************************************************************************
variable "core_vnet_address_space" {
  default = ["10.6.0.0/16", "2001:db8::/48"]
}
variable "appgw_subnet_address_space" {
  default = "10.6.0.0/24"
}

variable "appgw_ipv6_subnet_address_space" {
  default = "10.6.3.0/24"
}
variable "gateway_subnet_address_space" {
  default = "10.6.1.0/24"
}
variable "dns_subnet_address_space" {
  default = "10.6.2.0/28"
}
variable "pe_subnet_address_space" {
  default = "10.6.2.16/28"
}

###Storage Variable
//***********************************************************************************************

// Required Variables Azure Storage Account
//**********************************************************************************************

// Required Variables Azure Key vault
//**********************************************************************************************
variable "tenant_id" {
  default = "c09fae9e-0750-4861-a01d-0dd6d9721be7"
}
//variable "caf_keyvault_private_dns_zone_


####Private DNS Zone Variables
variable "private_dns_zone_map" {
  default = ["crowdbotics.com", "privatelink.azurecr.io", "privatelink.blob.core.windows.net", "privatelink.postgres.database.azure.com", "privatelink.redis.cache.windows.net", "privatelink.servicebus.windows.net", "privatelink.vaultcore.azure.net"]
}

###Public IP Address Variables
variable "public_ip_map" {
  default = {
    appgw = {
      purpose           = "appgw"
      pip_zones         = ["2"]
      allocation_method = "Static"
      pip_sku           = "Standard"
      version           = "IPv4"
    },
    appgw_ipv6 = {
      purpose           = "appgw_ipv6"
      pip_zones         = ["2"]
      allocation_method = "Static"
      pip_sku           = "Standard"
      version           = "IPv6"
    },
    appgw_ipv4 = {
      purpose           = "appgw_ipv4"
      pip_zones         = ["2"]
      allocation_method = "Static"
      pip_sku           = "Standard"
      version           = "IPv4"
    },
    vgw = {
      purpose           = "vgw"
      pip_zones         = []
      allocation_method = "Static"
      pip_sku           = "Standard"
      version           = "IPv4"
    }
  }
}


####Application Gateway Variables
variable "frontend_port_map" {
  default = {
    port_80 = {
      frontend_port_name = "port_80"
      port               = 80
    },
    port_443 = {
      frontend_port_name = "port_443"
      port               = 443
    }
  }
}

variable "ssl_certificate_password" {
  default = "Admin@123"
}

####Virtual Network Gateway Variables
variable "vgw_sku" {
  default = "VpnGw1"
}

####Local Network Gateway Variables
variable "local_network_gateway_map" {
  default = {
    aws01 = {
      purpose             = "cbaws"
      suffix_lgw          = "001"
      lgw_gateway_address = "35.174.103.199"
      local_address_space = ["10.5.0.0/16"]
    },
    aws02 = {
      purpose             = "cbaws"
      suffix_lgw          = "002"
      lgw_gateway_address = "54.158.78.148"
      local_address_space = ["10.5.0.0/16"]
    }
  }
}

###Key vault Secret Variable
variable "caf_key_vault_secret_map" {
  default = {
    "01" = {
      secret_name  = "AWSTunnelConnectionKey-1"
      secret_value = "s_d..Y50JN3voAIFFCsWpx3EQj48d_4r"
    },
    "02" = {
      secret_name  = "AWSTunnelConnectionKey-2"
      secret_value = "LvRUTL82eip2NS1rIUECqG3Q7WRecn8l"
    }
  }
}

variable "policycount" {
  type    = bool
  default = true
}

variable "cloudamqp_config" {
  type = map(any)
  default = {
    planId                   = "cloudamqp-hosting"
    offerId                  = "cloudamqp-v4"
    publisherId              = "84codes"
    termId                   = "gmz7xq9ge3py"
    publisherTestEnvironment = ""
    location                 = "global"
  }
}

variable "cloudamqp_autorenew" {
  type    = bool
  default = true
}

variable "cloudamqp_quantity" {
  type    = number
  default = 1
}

variable "azureSubscriptionId" {
  type    = string
  default = "85d89dad-c139-48fb-b3ed-8902eb8b0a3a"
}

variable "cdn_sku" {
  type        = string
  description = "(Required) The pricing related information of current CDN profile. Accepted values are Standard_Akamai, Standard_ChinaCdn, Standard_Microsoft, Standard_Verizon or Premium_Verizon. Changing this forces a new resource to be created."
  default     = "Standard_Verizon"
}

variable "cdn_config" {
  type = map(any)
  default = {
    dev = {
      storage_account_name = "stgcbcoredev001"
    }
    qa = {
      storage_account_name = "stgcbcoreqa01"
    }
    stg = {
      storage_account_name = "stgcbcorestg01"
    }
    prod = {
      storage_account_name = "stgcbcoreprod01"
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

variable "slack_channel_id" {
  description = "The Slack Channel ID for Key Vault Monitoring - Channel Name - azure-vault-notification"
  default     = "C07KH1569U6"
}

variable "slack_channel_quota_id" {
  description = "The Slack CHannel ID for Resource Quota Alerts - Channel Name - azure-quota-notification"
  default     = "C07LY9MQ7TJ"
}

# Variables
variable "resource_quota_subscription_ids" {
  description = "List of subscription IDs to monitor for resource quota alerts."
  type        = list(string)
  default     = ["88a89f8b-0b06-4ab8-ac9f-d59c57422ad6", "c96b1579-3994-45ad-bdc8-d2bb03bed4fa", "7994c938-91d9-46db-afed-6e49669438da", "f0cd098d-47c6-45e3-9972-ee2e8ec9e2ce", "c5a9afc7-3cb1-4292-b012-d7ccc5708b6c"]
}