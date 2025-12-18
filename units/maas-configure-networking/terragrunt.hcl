include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/maas-configure-networking"
}

dependency "maas_setup" {
  config_path = values.maas_setup_path

  mock_outputs = {
    maas_api_url = "http://maas.example.com/MAAS/api/2.0/"
    maas_api_key = "0123456789abcdef0123456789abcdef01234567:secondpart:thirdpart"
  }

}

dependency "maas_config" {
  config_path = values.maas_config_path

  mock_outputs = {
    # Add mock outputs if needed
  }
}

inputs = {
  maas_url = dependency.maas_setup.outputs.maas_api_url
  maas_key = dependency.maas_setup.outputs.maas_api_key
  spaces   = values.spaces
  fabrics  = values.fabrics
}
