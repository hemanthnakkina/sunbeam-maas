output "vm_machines" {
  description = "Map of created VM machines with their details"
  value = {
    for k, vm in maas_vm_host_machine.vm : k => {
      id        = vm.id
      hostname  = vm.hostname
      vm_host   = vm.vm_host
      cores     = vm.cores
      memory    = vm.memory
      pool      = vm.pool
      zone      = vm.zone
      system_id = vm.id
    }
  }
}

output "vm_hostnames" {
  description = "List of all VM hostnames created"
  value       = [for vm in maas_vm_host_machine.vm : vm.hostname]
}

output "vm_system_ids" {
  description = "Map of VM keys to their system IDs"
  value       = { for k, vm in maas_vm_host_machine.vm : k => vm.id }
}
