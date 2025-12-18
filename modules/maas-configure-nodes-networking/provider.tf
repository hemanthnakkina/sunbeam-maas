terraform {
  required_version = ">= 1.0"
  required_providers {
    maas = {
      source  = "canonical/maas"
      version = ">= 2.0"
    }
  }
}
provider "maas" {
  api_key = var.maas_key
  api_url = var.maas_url
}

