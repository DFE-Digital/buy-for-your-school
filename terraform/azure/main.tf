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
  skip_provider_registration = true
  subscription_id            = var.app_subscription_id
}

provider "azurerm" {
  alias = "prod"

  features {}
  skip_provider_registration = true
  subscription_id            = var.production_subscription_id
}

