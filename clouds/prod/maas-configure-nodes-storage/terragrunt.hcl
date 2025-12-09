terraform {
  source = "../../../modules/maas-configure-nodes-storage"

  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
    
    optional_var_files = [
      "${get_terragrunt_dir()}/storage_profiles.tfvars",
      "${get_terragrunt_dir()}/storage.tfvars"
    ]
  }
}

# Dependency on maas-enlist-machines - machines must exist before configuring storage
# dependency "machines" {
#   config_path = "../maas-enlist-machines"
#   
#   mock_outputs = {
#     machine_ids = {
#       "compute-1.maas" = "mock-machine-id-1"
#       "compute-2.maas" = "mock-machine-id-2"
#       "compute-3.maas" = "mock-machine-id-3"
#     }
#   }
#   
#   skip_outputs = true
# }

# Dependency on maas-configure-nodes - node configuration (including networking) must be complete
# dependency "node_config" {
#   config_path = "../maas-configure-nodes"
#   
#   mock_outputs = {
#     configured_machines = {
#       "compute-1" = "mock-machine-1"
#       "compute-2" = "mock-machine-2"
#     }
#   }
#   
#   skip_outputs = true
# }
