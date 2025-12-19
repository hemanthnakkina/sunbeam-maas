# MAAS Machines - Dynamically enlist machines based on the machines variable

locals {
  # Collect tags and associated machines
  tags_to_host = {
    for tag in distinct(flatten([
      for name, machine in var.machines : try(machine.tags, [])
      ])) : tag => [
      for name, machine in var.machines :
      name if contains(try(machine.tags, []), tag)
    ]
  }
}

module "machine" {
  for_each = var.machines
  source   = "./modules/machine"

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

resource "maas_tag" "vm_tags" {
  depends_on = [module.machine]
  for_each   = { for tag, hosts in local.tags_to_host : tag => hosts if hosts != null }

  name     = each.key
  machines = each.value
}

