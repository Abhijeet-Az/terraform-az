// Resource group
//**********************************************************************************************
resource "azurerm_resource_group" "caf_resource_group" {
  name     = "rg-${var.env_prefix}-${var.location}-${var.suffix}"
  location = var.location
  tags     = var.tags
  lifecycle {
    prevent_destroy = true
  }
}
//**********************************************************************************************
