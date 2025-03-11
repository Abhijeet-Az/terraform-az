terraform {
  required_version = ">= 0.13"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

#provider "kubectl" {
#  load_config_file = true
#  config_path      = "~/.kube/config"
#  config_context   = "aks-cbcore-dev-001"
#}

data "azurerm_kubernetes_cluster" "aks" {
  name                = var.kube_config[var.environment].name
  resource_group_name = var.kube_config[var.environment].resource_group_name
}

provider "kubectl" {
  host                   = data.azurerm_kubernetes_cluster.aks.kube_admin_config.0.host
  username               = data.azurerm_kubernetes_cluster.aks.kube_admin_config.0.username
  password               = data.azurerm_kubernetes_cluster.aks.kube_admin_config.0.password
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_admin_config.0.cluster_ca_certificate)
  load_config_file       = false
}