# MAAS Configure Networking Unit - Manage MAAS networking resources
terraform {
  source = "."

  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
    
    optional_var_files = [
      "${get_terragrunt_dir()}/networking.tfvars"
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

# Generate main.tf that calls the module
generate "main" {
  path      = "main.tf"
  if_exists = "overwrite"
  contents  = <<-EOT
# MAAS Networking Configuration

module "maas_configure_networking" {
  source = "${get_terragrunt_dir()}/../../../modules/maas-configure-networking"

  # Pass variables from tfvars
  spaces  = var.spaces
  fabrics = var.fabrics
}

# Outputs
output "spaces" {
  value = module.maas_configure_networking.spaces
}

output "fabrics" {
  value = module.maas_configure_networking.fabrics
}

output "vlans" {
  value = module.maas_configure_networking.vlans
}

output "subnets" {
  value = module.maas_configure_networking.subnets
}

output "ip_ranges" {
  value = module.maas_configure_networking.ip_ranges
}
EOT
}

# Generate provider.tf
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<-EOT
terraform {
  required_providers {
    maas = {
      source  = "canonical/maas"
      version = "~> 2.6.0"
    }
  }
}

provider "maas" {
  api_version = var.maas_api_version
  api_key     = var.maas_api_key
  api_url     = var.maas_api_url
}
EOT
}

# Inputs for MAAS API credentials (from dependency)
inputs = {
  maas_api_url     = dependency.maas_setup.outputs.maas_api_url
  maas_api_key     = dependency.maas_setup.outputs.maas_api_key
  maas_api_version = "2.0"
}
