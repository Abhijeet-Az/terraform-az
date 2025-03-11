resource "azurerm_marketplace_agreement" "subscription" {
  publisher = "84codes"
  offer     = "CloudAMQP"
  plan      = "monthly"
}

resource "azurerm_resource_group_template_deployment" "deployment" {
  name                = "cloudamqp_template"
  resource_group_name = module.caf_resource_group.caf_resource_group.name
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "name" = {
      value = "cloudamqp-${var.environment}-${var.location}-${var.suffix}"
    },
    "publisherId" = {
      value = var.cloudamqp_config.publisherId
    },
    "offerId" = {
      value = var.cloudamqp_config.offerId
    },
    "planId" = {
      value = var.cloudamqp_config.planId
    },
    "termId" = {
      value = var.cloudamqp_config.termId
    },
    "quantity" = {
      value = var.cloudamqp_quantity
    },
    "azureSubscriptionId" = {
      value = var.azureSubscriptionId
    },
    "autoRenew" = {
      value = var.cloudamqp_autorenew
    }
  })
  template_content = file("saas-arm.json")
}