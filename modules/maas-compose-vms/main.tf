terraform {
  required_version = ">= 1.6"
  required_providers {
    maas = {
      source  = "canonical/maas"
      version = "~> 2.6"
    }
  }
}

locals {
  # Create a flat list of VM instances based on count
  vm_instances = flatten([
    for vm_key, vm_config in var.vm_configurations : [
      for i in range(vm_config.count) : {
        # vm_host is an optional list; assign element i when available, otherwise use last element
        vm_host = vm_config.vm_host != null ? (length(vm_config.vm_host) > i ? vm_config.vm_host[i] : vm_config.vm_host[length(vm_config.vm_host) - 1]) : null
        # Use per-VM zone (list) and pool
        # zone is an optional list; assign element i when available, otherwise use last element
        zone = vm_config.zone != null ? (length(vm_config.zone) > i ? vm_config.zone[i] : vm_config.zone[length(vm_config.zone) - 1]) : null
        pool = vm_config.pool
        # Build key
        key = "${vm_key}-${i}"
        # Build hostname
        hostname      = "${coalesce(vm_config.hostname_prefix, vm_key)}-${i}"
        cores         = vm_config.cores
        pinned_cores  = vm_config.pinned_cores
        memory        = vm_config.memory
        storage_disks = vm_config.storage_disks
        network       = vm_config.network
        tags          = vm_config.tags
      }
    ]
  ])

  # Create a map for easier resource creation
  vm_instances_map = {
    for vm in local.vm_instances : vm.key => vm
  }
}

resource "maas_vm_host_machine" "vm" {
  for_each = local.vm_instances_map

  vm_host  = each.value.vm_host
  cores    = each.value.cores
  memory   = each.value.memory
  hostname = each.value.hostname
  pool     = each.value.pool
  zone     = each.value.zone

  dynamic "storage_disks" {
    for_each = each.value.storage_disks != null ? each.value.storage_disks : []
    content {
      size_gigabytes = storage_disks.value.size_gigabytes
      pool           = storage_disks.value.pool
    }
  }

  dynamic "network_interfaces" {
    for_each = each.value.network != null ? each.value.network : []
    content {
      name        = network_interfaces.value.name
      fabric      = network_interfaces.value.fabric
      vlan        = network_interfaces.value.vlan
      subnet_cidr = network_interfaces.value.subnet_cidr
      ip_address  = network_interfaces.value.ip_address
    }
  }
}

# Apply tags to VMs
resource "maas_tag" "vm_tags" {
  for_each = {
    for item in flatten([
      for vm_key, vm in local.vm_instances_map : [
        for tag in vm.tags : {
          key      = "${vm_key}-${tag}"
          tag      = tag
          machines = [maas_vm_host_machine.vm[vm_key].id]
        }
      ]
    ]) : item.key => item
  }

  name     = each.value.tag
  machines = each.value.machines
}
