include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git::https://github.com/canonical/maas-terraform-modules.git//modules/maas-config?ref=main"
}

dependency "maas_setup" {
  config_path = values.maas_setup_path

  mock_outputs = {
    maas_api_url = "http://maas.example.com/MAAS/api/2.0/"
    maas_api_key = "0123456789abcdef0123456789abcdef01234567:secondpart:thirdpart"
  }
}

inputs = {
  maas_url        = dependency.maas_setup.outputs.maas_api_url
  maas_key        = dependency.maas_setup.outputs.maas_api_key
  boot_selections = values.boot_selections
  domains         = values.domains
  # Additional MAAS configuration
  # maas_config = {}
  # tags = {}
}
