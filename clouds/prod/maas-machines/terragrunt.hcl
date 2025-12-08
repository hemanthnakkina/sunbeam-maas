# MAAS Machines Unit - Enlist multiple machines
terraform {
  source = "."

  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
    
    optional_var_files = [
      "${get_terragrunt_dir()}/tfvars.json",
      "${get_terragrunt_dir()}/machines.tfvars"
    ]
  }
}

# Dependencies - this module depends on maas-setup (for API credentials)
dependency "maas_setup" {
  config_path = "../maas-setup"
  
  mock_outputs = {
    maas_api_url = "http://mock-maas-api:5240/MAAS"
    maas_api_key = "mock-api-key:mock-token:mock-secret"
  }
  
  # Skip outputs if the dependency hasn't been applied yet
  skip_outputs = true
}

dependency "maas_config" {
  config_path = "../maas-config"
  
  mock_outputs = {
    maas_configured = true
  }
  
  # Skip outputs if the dependency hasn't been applied yet
  skip_outputs = true
}

locals {
  # Machines will be loaded from tfvars file, not from locals
  # This is just a placeholder for the generate block
  machines = {}
}

# Note: Remove or comment out the skip line below when ready to enlist machines
# skip = true

# Generate main.tf with dynamic machine module calls
generate "main" {
  path      = "main.tf"
  if_exists = "overwrite"
  contents  = <<-EOT
# MAAS Machines - Dynamically enlist machines based on the machines variable

module "machine" {
  for_each = var.machines
  source   = "${get_terragrunt_dir()}/../../../modules/machine"

  power_type = each.value.power_type
  power_parameters = jsonencode({
    power_address   = each.value.power_address
    power_user      = try(each.value.power_user, null)
    power_pass      = try(each.value.power_pass, null)
    power_driver    = try(each.value.power_driver, null)
    power_boot_type = try(each.value.power_boot_type, null)
    cipher_suite_id = try(each.value.cipher_suite_id, null)
  })

  pxe_mac_address = each.value.pxe_mac_address
  hostname        = each.key
  zone            = try(each.value.zone, null)
  architecture    = try(each.value.architecture, "amd64/generic")
}
  EOT
}

inputs = {
  # MAAS API credentials from maas-setup module
  maas_api_url     = dependency.maas_setup.outputs.maas_api_url
  maas_api_key     = dependency.maas_setup.outputs.maas_api_key
  maas_api_version = "2.0"
  
  # Machines variable will be loaded from tfvars file
}

