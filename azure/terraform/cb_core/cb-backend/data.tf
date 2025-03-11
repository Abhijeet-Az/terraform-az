####Data Blocks from terraform remote state

data "terraform_remote_state" "shared" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-terraform-eastus-001"
    storage_account_name = "stgsbtfshared001"
    container_name       = "tfstate-shared"
    key                  = "cb.shared.tfstate"
    subscription_id      = "85d89dad-c139-48fb-b3ed-8902eb8b0a3a"
  }
}

data "azurerm_client_config" "current" {}

data "azurerm_key_vault_secret" "slack_webhook_uri" {
  name         = local.slack_webhook_kv_secret_name
  key_vault_id = module.caf_azure_keyvault.caf_keyvault.id
}
data "azurerm_key_vault_secret" "psql_admin_pwd" {
  name         = local.psql_admin_pwd_secret_name
  key_vault_id = module.caf_azure_keyvault.caf_keyvault.id
}