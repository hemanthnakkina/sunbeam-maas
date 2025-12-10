# MAAS Setup - Install and configure MAAS using Canonical's maas-deploy module
include "env" {
  path   = find_in_parent_folders("env.hcl")
  expose = true
}

terraform {
  # Using Canonical's maas-terraform-modules from GitHub
  # Reference: https://github.com/canonical/maas-terraform-modules/tree/main/modules/maas-deploy
  source = "git::https://github.com/canonical/maas-terraform-modules.git//modules/maas-deploy?ref=main"
}

# Dependencies - this module depends on juju-bootstrap
dependency "juju_bootstrap" {
  config_path = "../juju-bootstrap"

  mock_outputs = {
    juju_cloud = "mock-juju-cloud"
  }

  # Skip outputs if the dependency hasn't been applied yet
  skip_outputs = true
}

locals {
  env_vars = include.env.locals
}

# Note: This unit is not currently active

inputs = {
  # Example inputs for when you're ready to deploy:
  # juju_cloud_name = "maas-charms"
  # admin_username  = "admin"
  # admin_password  = "changeme"
  # admin_email     = "admin@example.com"
}

# This module outputs:
# - maas_api_url: MAAS API URL endpoint
# - maas_api_key: MAAS admin API key
# - maas_machines: List of MAAS machine hostnames (if Region+Rack mode)
