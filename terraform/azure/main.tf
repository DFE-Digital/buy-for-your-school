terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.62.1"
    }
  }
 backend "azurerm" {}
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  subscription_id            = var.app_subscription_id
}

provider "azurerm" {
  alias = "prod"

  features {}
  resource_provider_registrations = "none"
  subscription_id            = var.production_subscription_id
}