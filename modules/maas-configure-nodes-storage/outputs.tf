output "block_devices" {
  description = "Map of configured block devices"
  value       = maas_block_device.devices
}

output "raids" {
  description = "Map of configured RAID arrays"
  value       = maas_raid.raids
}

output "volume_groups" {
  description = "Map of configured volume groups"
  value       = maas_volume_group.vgs
}

output "logical_volumes" {
  description = "Map of configured logical volumes"
  value       = maas_logical_volume.lvs
}
