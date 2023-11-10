terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "istio_request_size_limit_exceeded_alert" {
  source    = "./modules/istio_request_size_limit_exceeded_alert"

  providers = {
    shoreline = shoreline
  }
}