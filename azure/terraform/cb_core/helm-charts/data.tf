data "azurerm_kubernetes_cluster" "aks" {
  name                = var.kube_config[var.environment].name
  resource_group_name = var.kube_config[var.environment].resource_group_name
}