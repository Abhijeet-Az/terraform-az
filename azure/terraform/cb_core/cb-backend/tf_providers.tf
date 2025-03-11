terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.11.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.0.2"
    }
    helm = {
      version = "2.14.0"
      source  = "hashicorp/helm"
    }
    cloudamqp = {
      source = "cloudamqp/cloudamqp"
    }
  }
}

provider "azurerm" {
  features {}
}

# Configure the CloudAMQP Provider
provider "cloudamqp" {
  enable_faster_instance_destroy = true
}
