# MAAS Configuration - Configure MAAS resources using Canonical's maas-config module
include "env" {
  path   = find_in_parent_folders("env.hcl")
  expose = true
}

terraform {
  # Using Canonical's maas-terraform-modules from GitHub
  # Reference: https://github.com/canonical/maas-terraform-modules/tree/main/modules/maas-config
  source = "git::https://github.com/canonical/maas-terraform-modules.git//modules/maas-config?ref=main"
}

# Dependencies - this module depends on maas-setup
dependency "maas_setup" {
  config_path = "../maas-setup"
  
  mock_outputs = {
    maas_api_url = "http://mock-maas-api:5240/MAAS"
    maas_api_key = "mock-api-key"
  }
  
  # Skip outputs if the dependency hasn't been applied yet
  skip_outputs = true
}

locals {
  env_vars = include.env.locals
}

# Note: This unit is not currently active

inputs = {
  # Example inputs for when you're ready to configure MAAS:
  # Use outputs from maas-setup module
  # maas_url = dependency.maas_setup.outputs.maas_api_url
  # maas_key = dependency.maas_setup.outputs.maas_api_key
  
  # Boot image configuration
  # boot_selections = {
  #   "jammy" = {
  #     arches = ["amd64"]
  #   }
  # }
  
  # Additional MAAS configuration
  # maas_config = {}
  # domains = {}
  # tags = {}
}
