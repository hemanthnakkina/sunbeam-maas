# MAAS Machine Module Outputs

output "id" {
  description = "The MAAS machine system ID"
  value       = maas_machine.machine.id
}

output "hostname" {
  description = "The hostname of the machine"
  value       = maas_machine.machine.hostname
}

output "zone" {
  description = "The availability zone of the machine"
  value       = maas_machine.machine.zone
}

output "pool" {
  description = "The resource pool of the machine"
  value       = maas_machine.machine.pool
}

output "power_type" {
  description = "The power type configured for the machine"
  value       = maas_machine.machine.power_type
}
