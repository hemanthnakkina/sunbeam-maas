# MAAS Enlist Machines Module
# Wraps the canonical/maas provider machine resource
# Reference: https://registry.terraform.io/providers/canonical/maas/latest/docs/resources/machine

resource "maas_machine" "machine" {
  # Power configuration
  power_type       = var.power_type
  power_parameters = var.power_parameters

  # PXE boot configuration (optional)
  pxe_mac_address = var.pxe_mac_address

  # Machine configuration
  hostname     = var.hostname
  zone         = var.zone
  architecture = var.architecture

  # Prevent power_parameters from being displayed in diffs
  lifecycle {
    ignore_changes = [
      power_parameters
    ]
  }
}
