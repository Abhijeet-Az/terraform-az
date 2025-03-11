variable "environment" {
  description = "value of environment"
}

variable "kube_config" {
  type = map(any)
  default = {
    dev = {
      name                = "aks-cbcore-dev-001"
      resource_group_name = "rg-dev-eastus-001"
    }
    # staging = {
    #   name                = "aks-cbcore-stg-01"
    #   resource_group_name = "rg-stg-eastus-01"
    # }
    qa = {
      name                = "aks-cbcore-qa-01"
      resource_group_name = "rg-qa-eastus-01"
    }
    production = {
      name                = "aks-cbcore-prod-01"
      resource_group_name = "rg-prod-eastus-01"
    }
  }
}