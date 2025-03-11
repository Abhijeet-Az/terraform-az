####Data Blocks from terraform remote state
data "terraform_remote_state" "dev" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-terraform-eastus-001"
    storage_account_name = "stgsbtfshared001"
    container_name       = "tfstate-dev"
    key                  = "cbcoretest.dev.tfstate"
  }
}
data "terraform_remote_state" "qa" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-terraform-eastus-001"
    storage_account_name = "stgsbtfshared001"
    container_name       = "tfstate-qa"
    key                  = "cbcoretest.qa.tfstate"
  }
}
# data "terraform_remote_state" "staging" {
#   backend = "azurerm"
#   config = {
#     resource_group_name  = "rg-terraform-eastus-001"
#     storage_account_name = "stgsbtfshared001"
#     container_name       = "tfstate-staging"
#     key                  = "cbcoretest.staging.tfstate"
#   }
# }
data "terraform_remote_state" "production" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-terraform-eastus-001"
    storage_account_name = "stgsbtfshared001"
    container_name       = "tfstate-production"
    key                  = "cbcoretest.production.tfstate"
  }
}

data "terraform_remote_state" "shared" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-terraform-eastus-001"
    storage_account_name = "stgsbtfshared001"
    container_name       = "tfstate-shared"
    key                  = "cb.shared.tfstate"
  }
}

data "azurerm_management_group" "Mgmt_Group_CB" {
  display_name = "Crowdbotics"
}

data "azurerm_management_group" "Mgmt_Group_LZ" {
  display_name = "Landing Zones"
}

data "azurerm_management_group" "Mgmt_Group_Platform" {
  display_name = "Platform"
}

data "azurerm_key_vault_secret" "slack_webhook_uri" {
  name         = local.slack_webhook_kv_secret_name
  key_vault_id = module.caf_azure_keyvault.caf_keyvault.id
}

data "azurerm_key_vault_secret" "slack_webhook_quota_updates_uri" {
  name         = local.slack_webhook_quota_updates_name
  key_vault_id = module.caf_azure_keyvault.caf_keyvault.id
}
