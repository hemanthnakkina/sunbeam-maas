terraform {
  required_version = ">= 1.0"

  required_providers {
    maas = {
      source  = "canonical/maas"
      version = "~> 2.6.0"
    }
  }
}
