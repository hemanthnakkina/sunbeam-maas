# MAAS Machines - Dynamically enlist machines based on the machines variable

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
