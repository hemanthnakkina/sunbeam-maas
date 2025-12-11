# MAAS Compose VMs Unit - Compose virtual machines on VM hosts
terraform {
  source = "../../../modules/maas-compose-vms"

  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
    
    optional_var_files = [
      "${get_terragrunt_dir()}/tfvars.json",
      "${get_terragrunt_dir()}/vms.tfvars"
    ]
  }
}

# Dependencies - this module depends on maas-setup
dependency "maas_setup" {
  config_path = "../maas-setup"
  
  mock_outputs = {
    maas_api_url = "http://mock-maas-api:5240/MAAS"
    maas_api_key = "mock-api-key:mock-token:mock-secret"
  }
  
  # Skip outputs if the dependency hasn't been applied yet
  skip_outputs = true
}

# Generate provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "maas" {
  api_version = "2.0"
  api_key     = var.maas_api_key
  api_url     = var.maas_api_url
}

variable "maas_api_url" {
  description = "MAAS API URL"
  type        = string
  sensitive   = true
}

variable "maas_api_key" {
  description = "MAAS API Key"
  type        = string
  sensitive   = true
}
EOF
}

# Pass MAAS credentials as inputs
inputs = {
  maas_api_url = dependency.maas_setup.outputs.maas_api_url
  maas_api_key = dependency.maas_setup.outputs.maas_api_key
}
