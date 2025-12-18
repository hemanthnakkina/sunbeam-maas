# Juju Bootstrap - Bootstrap Juju controller using Canonical's juju-bootstrap module
include "env" {
  path   = find_in_parent_folders("env.hcl")
  expose = true
}

terraform {
  # Using Canonical's maas-terraform-modules from GitHub
  # Reference: https://github.com/canonical/maas-terraform-modules/tree/main/modules/juju-bootstrap
  source = "git::https://github.com/canonical/maas-terraform-modules.git//modules/juju-bootstrap?ref=main"
}

locals {
  env_vars = include.env.locals
}

# Note: This unit is not currently active

inputs = {
  # Example inputs for when you're ready to bootstrap Juju:
  # cloud_name       = "maas-charms"
  # lxd_address      = "https://10.0.0.1:8443"
  # lxd_project      = "maas-charms"
  # lxd_trust_token  = "<your-lxd-trust-token>"
}

# This module outputs:
# - juju_cloud: The name of the Juju cloud that was created
