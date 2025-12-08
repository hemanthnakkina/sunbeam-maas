# Root terragrunt.hcl
# This file contains common configuration for all clouds

locals {
  # Load common variables
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl", "skip"), {locals = {}})
}

# Configure Terraform
terraform {
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
    
    optional_var_files = [
      find_in_parent_folders("common.tfvars", "ignore"),
      find_in_parent_folders("cloud.tfvars", "ignore"),
      find_in_parent_folders("env.tfvars", "ignore"),
    ]
  }
}

# Global inputs that will be passed to all modules
inputs = {
  project_name = "sunbeam-maas"
}
