terraform {
  source = "../../../modules/maas-configure-nodes-networking"

  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
    
    optional_var_files = [
      "${get_terragrunt_dir()}/network_profiles.tfvars",
      "${get_terragrunt_dir()}/nodes.tfvars"
    ]
  }
}

# Dependency on maas-enlist-machines - machines must exist before configuring them
dependency "machines" {
  config_path = "../maas-enlist-machines"
  
  mock_outputs = {
    machine_ids = {
      "compute-1.maas" = "mock-machine-id-1"
      "compute-2.maas" = "mock-machine-id-2"
      "compute-3.maas" = "mock-machine-id-3"
    }
  }
  
  skip_outputs = true
}

# Dependency on maas-configure-networking - networking must be set up first
dependency "networking" {
  config_path = "../maas-configure-networking"
  
  mock_outputs = {
    subnet_ids = {
      "mgmt"    = "mock-subnet-mgmt"
      "data"    = "mock-subnet-data"
      "storage" = "mock-subnet-storage"
    }
  }
  
  skip_outputs = true
}
