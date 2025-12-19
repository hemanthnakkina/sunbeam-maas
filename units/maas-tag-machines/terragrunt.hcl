include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/maas-tag-machines"
}

dependencies {
  paths = try(values.dependencies, [])
}

dependency "maas_setup" {
  config_path = values.maas_setup_path

  mock_outputs = {
    maas_api_url = "http://mock-maas-api:5240/MAAS"
    maas_api_key = "mock-api-key:mock-token:mock-secret"
  }
}

inputs = {
  maas_url = dependency.maas_setup.outputs.maas_api_url
  maas_key = dependency.maas_setup.outputs.maas_api_key
  tags     = values.tags
}
