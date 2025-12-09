terraform {
  required_providers {
    maas = {
      source  = "canonical/maas"
      version = "~> 2.0"
    }
  }
}

provider "maas" {
  api_url = var.maas_api_url
  api_key = var.maas_api_key
}

variable "maas_api_url" {
  description = "MAAS API URL"
  type        = string
}

variable "maas_api_key" {
  description = "MAAS API key"
  type        = string
  sensitive   = true
}
