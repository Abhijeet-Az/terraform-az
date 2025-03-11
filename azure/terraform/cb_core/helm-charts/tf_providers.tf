terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.101.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.36.0"
    }
    helm = {
      version = "2.14.0"
      source  = "hashicorp/helm"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.aks.kube_admin_config.0.host
    username               = data.azurerm_kubernetes_cluster.aks.kube_admin_config.0.username
    password               = data.azurerm_kubernetes_cluster.aks.kube_admin_config.0.password
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_admin_config.0.cluster_ca_certificate)
  }
}
