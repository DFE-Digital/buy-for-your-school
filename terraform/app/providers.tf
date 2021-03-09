provider "cloudfoundry" {
  api_url = "https://api.london.cloud.service.gov.uk"
}

terraform {
  required_providers {
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "~> 0.13.0"
    }
  }
}
