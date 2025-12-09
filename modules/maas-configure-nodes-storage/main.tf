locals {
  # Merge profile-based and inline configurations for each machine
  merged_machines = {
    for machine_key, machine in var.nodes : machine_key => {
      hostname = machine.hostname
      profile  = lookup(machine, "storage_profile", null)

      # Merge devices from profile mapping and inline block_devices
      devices = merge(
        lookup(machine, "devices", {}),
        {
          for bd_key, bd in lookup(machine, "block_devices", {}) : bd_key => {
            name           = bd.name
            id_path        = lookup(bd, "id_path", null)
            model          = lookup(bd, "model", null)
            serial         = lookup(bd, "serial", null)
            size_gigabytes = lookup(bd, "size_gigabytes", 0)
            block_size     = lookup(bd, "block_size", null)
            is_boot_device = lookup(bd, "is_boot_device", false)
            tags           = lookup(bd, "tags", [])
          }
        }
      )

      # Get partition layout: from profile or inline
      partition_layouts = machine.storage_profile != null ? lookup(var.storage_profiles[machine.storage_profile], "partitions", {}) : {
        for bd_key, bd in lookup(machine, "block_devices", {}) : bd_key => lookup(bd, "partitions", [])
      }

      # Get RAID config: from profile or inline
      raids = machine.storage_profile != null ? lookup(var.storage_profiles[machine.storage_profile], "raids", {}) : lookup(machine, "raids", {})

      # Get VG config: from profile or inline
      volume_groups = machine.storage_profile != null ? lookup(var.storage_profiles[machine.storage_profile], "volume_groups", {}) : lookup(machine, "volume_groups", {})

      # Get LV config: from profile or inline
      logical_volumes = machine.storage_profile != null ? lookup(var.storage_profiles[machine.storage_profile], "logical_volumes", {}) : lookup(machine, "logical_volumes", {})
    }
  }

  # Create a map of block device partitions with their indices for reference
  # Format: "machine_key.device_key.partition_index" => partition details
  block_device_partitions = {
    for part in flatten([
      for machine_key, machine in local.merged_machines : [
        for device_key, partitions in machine.partition_layouts : [
          for idx, partition in partitions : {
            key             = "${machine_key}.${device_key}.${idx}"
            machine_key     = machine_key
            device_key      = device_key
            partition_index = idx
            tags            = lookup(partition, "tags", [])
          }
        ]
      ]
    ]) : part.key => part
  }

  # Flatten block devices for all machines
  block_devices = flatten([
    for machine_key, machine in local.merged_machines : [
      for device_key, device in machine.devices : {
        machine_key    = machine_key
        machine_name   = machine.hostname
        device_key     = device_key
        name           = device.name
        id_path        = lookup(device, "id_path", null)
        model          = lookup(device, "model", null)
        serial         = lookup(device, "serial", null)
        size_gigabytes = lookup(device, "size_gigabytes", 0)
        block_size     = lookup(device, "block_size", null)
        is_boot_device = lookup(device, "is_boot_device", false)
        tags           = lookup(device, "tags", [])
        partitions     = lookup(machine.partition_layouts, device_key, [])
      }
    ]
  ])

  # Flatten RAID arrays for all machines
  raids = flatten([
    for machine_key, machine in local.merged_machines : [
      for raid_key, raid in machine.raids : {
        machine_key   = machine_key
        machine_name  = machine.hostname
        raid_key      = raid_key
        name          = raid.name
        level         = raid.level
        block_devices = lookup(raid, "block_devices", [])
        partitions    = lookup(raid, "partitions", [])
        # Collect partition indices tagged with "raid:<raid_key>"
        tagged_partition_keys = [
          for part_key, part in local.block_device_partitions :
          "${part.device_key}.${part.partition_index}"
          if part.machine_key == machine_key && contains(part.tags, "raid:${raid_key}")
        ]
        spare_devices    = lookup(raid, "spare_devices", [])
        spare_partitions = lookup(raid, "spare_partitions", [])
        # Collect spare partition indices tagged with "raid-spare:<raid_key>"
        tagged_spare_partition_keys = [
          for part_key, part in local.block_device_partitions :
          "${part.device_key}.${part.partition_index}"
          if part.machine_key == machine_key && contains(part.tags, "raid-spare:${raid_key}")
        ]
        fs_type       = lookup(raid, "fs_type", null)
        mount_point   = lookup(raid, "mount_point", null)
        mount_options = lookup(raid, "mount_options", null)
      }
    ]
  ])

  # Flatten volume groups for all machines
  volume_groups = flatten([
    for machine_key, machine in local.merged_machines : [
      for vg_key, vg in machine.volume_groups : {
        machine_key   = machine_key
        machine_name  = machine.hostname
        vg_key        = vg_key
        name          = vg.name
        block_devices = lookup(vg, "block_devices", [])
        partitions    = lookup(vg, "partitions", [])
        # Collect partition indices tagged with "vg:<vg_key>"
        tagged_partition_keys = [
          for part_key, part in local.block_device_partitions :
          "${part.device_key}.${part.partition_index}"
          if part.machine_key == machine_key && contains(part.tags, "vg:${vg_key}")
        ]
      }
    ]
  ])

  # Flatten logical volumes for all machines
  logical_volumes = flatten([
    for machine_key, machine in local.merged_machines : [
      for lv_key, lv in machine.logical_volumes : {
        machine_key    = machine_key
        machine_name   = machine.hostname
        lv_key         = lv_key
        name           = lv.name
        volume_group   = lv.volume_group
        size_gigabytes = lv.size_gigabytes
        fs_type        = lookup(lv, "fs_type", null)
        mount_point    = lookup(lv, "mount_point", null)
        mount_options  = lookup(lv, "mount_options", null)
      }
    ]
  ])
}

# Data source to look up machines by hostname
data "maas_machine" "machines" {
  for_each = var.nodes
  hostname = each.value.hostname
}

# Configure block devices
resource "maas_block_device" "devices" {
  for_each = {
    for bd in local.block_devices : "${bd.machine_key}.${bd.device_key}" => bd
  }

  machine        = data.maas_machine.machines[each.value.machine_key].id
  name           = each.value.name
  id_path        = each.value.id_path
  model          = each.value.model
  serial         = each.value.serial
  size_gigabytes = each.value.size_gigabytes
  block_size     = each.value.block_size
  is_boot_device = each.value.is_boot_device
  tags           = each.value.tags

  dynamic "partitions" {
    for_each = each.value.partitions
    content {
      size_gigabytes = partitions.value.size_gigabytes
      fs_type        = partitions.value.fs_type
      label          = partitions.value.label
      bootable       = partitions.value.bootable
      mount_point    = partitions.value.mount_point
      mount_options  = partitions.value.mount_options
      tags           = partitions.value.tags
    }
  }
}

# Create RAID arrays
resource "maas_raid" "raids" {
  for_each = {
    for r in local.raids : "${r.machine_key}.${r.raid_key}" => r
  }

  machine = data.maas_machine.machines[each.value.machine_key].id
  name    = each.value.name
  level   = each.value.level

  # Block device IDs for RAID
  block_devices = [
    for bd in each.value.block_devices :
    maas_block_device.devices["${each.value.machine_key}.${bd}"].id
  ]

  # Partition IDs for RAID: merge explicit IDs + partition IDs from tagged partitions
  partitions = concat(
    # Handle explicit partitions - can be either IDs (numbers) or references ("device.index")
    [
      for p in each.value.partitions :
      can(tonumber(p)) ? tonumber(p) :
      maas_block_device.devices["${each.value.machine_key}.${split(".", p)[0]}"].partitions[tonumber(split(".", p)[1])].id
    ],
    [
      for idx in each.value.tagged_partition_keys :
      maas_block_device.devices["${each.value.machine_key}.${split(".", idx)[0]}"].partitions[tonumber(split(".", idx)[1])].id
    ]
  )

  # Spare device IDs
  spare_devices = [
    for sd in each.value.spare_devices :
    maas_block_device.devices["${each.value.machine_key}.${sd}"].id
  ]

  # Spare partition IDs: merge explicit IDs + partition IDs from tagged spare partitions
  spare_partitions = concat(
    # Handle explicit spare partitions - can be either IDs (numbers) or references ("device.index")
    [
      for p in each.value.spare_partitions :
      can(tonumber(p)) ? tonumber(p) :
      maas_block_device.devices["${each.value.machine_key}.${split(".", p)[0]}"].partitions[tonumber(split(".", p)[1])].id
    ],
    [
      for idx in each.value.tagged_spare_partition_keys :
      maas_block_device.devices["${each.value.machine_key}.${split(".", idx)[0]}"].partitions[tonumber(split(".", idx)[1])].id
    ]
  )

  # Filesystem configuration
  fs_type       = each.value.fs_type
  mount_point   = each.value.mount_point
  mount_options = each.value.mount_options

  depends_on = [maas_block_device.devices]
}

# Create volume groups
resource "maas_volume_group" "vgs" {
  for_each = {
    for vg in local.volume_groups : "${vg.machine_key}.${vg.vg_key}" => vg
  }

  machine = data.maas_machine.machines[each.value.machine_key].id
  name    = each.value.name

  # Block device IDs in volume group
  # Can reference either regular block devices or RAID arrays (which become block devices)
  block_devices = concat(
    [
      for bd in each.value.block_devices :
      contains(keys(maas_block_device.devices), "${each.value.machine_key}.${bd}") ?
      maas_block_device.devices["${each.value.machine_key}.${bd}"].id :
      maas_raid.raids["${each.value.machine_key}.${bd}"].id
    ]
  )

  # Partition IDs in volume group: merge explicit IDs + partition IDs from tagged partitions
  partitions = concat(
    # Handle explicit partitions - can be either IDs (numbers) or references ("device.index")
    [
      for p in each.value.partitions :
      can(tonumber(p)) ? tonumber(p) :
      maas_block_device.devices["${each.value.machine_key}.${split(".", p)[0]}"].partitions[tonumber(split(".", p)[1])].id
    ],
    [
      for idx in each.value.tagged_partition_keys :
      maas_block_device.devices["${each.value.machine_key}.${split(".", idx)[0]}"].partitions[tonumber(split(".", idx)[1])].id
    ]
  )

  depends_on = [maas_block_device.devices, maas_raid.raids]
}

# Create logical volumes
resource "maas_logical_volume" "lvs" {
  for_each = {
    for lv in local.logical_volumes : "${lv.machine_key}.${lv.lv_key}" => lv
  }

  machine        = data.maas_machine.machines[each.value.machine_key].id
  name           = each.value.name
  volume_group   = maas_volume_group.vgs["${each.value.machine_key}.${each.value.volume_group}"].id
  size_gigabytes = each.value.size_gigabytes
  fs_type        = each.value.fs_type
  mount_point    = each.value.mount_point
  mount_options  = each.value.mount_options

  depends_on = [maas_volume_group.vgs]
}
