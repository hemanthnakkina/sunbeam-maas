include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/stub-maas-setup"
}


inputs = {
  maas_api_url = values.maas_api_url
  maas_api_key = values.maas_api_key
}
