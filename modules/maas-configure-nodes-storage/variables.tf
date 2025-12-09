variable "storage_profiles" {
  description = "Storage profiles defining partition layouts, RAID, and LVM configurations"
  type = map(object({
    # Partition layout per device
    # Key is the device role (e.g., "disk1", "disk2"), value is partition config
    partitions = optional(map(list(object({
      size_gigabytes = number
      fs_type        = optional(string)
      label          = optional(string)
      bootable       = optional(bool)
      mount_point    = optional(string)
      mount_options  = optional(string)
      tags           = optional(list(string), [])
    }))), {})

    # RAID arrays
    # - partitions can be: IDs (e.g., [123, 124]) or references (e.g., ["disk1.0", "disk2.0"])
    # - or use tags like "raid:<name>" for auto-discovery
    raids = optional(map(object({
      name             = string
      level            = number
      block_devices    = optional(list(string), [])
      partitions       = optional(list(string), [])
      spare_devices    = optional(list(string), [])
      spare_partitions = optional(list(string), [])
      fs_type          = optional(string)
      mount_point      = optional(string)
      mount_options    = optional(string)
    })), {})

    # Volume groups
    # - partitions can be: IDs (e.g., [123, 124]) or references (e.g., ["disk1.0", "disk2.0"])
    # - or use tags like "vg:<name>" for auto-discovery
    volume_groups = optional(map(object({
      name          = string
      block_devices = optional(list(string), [])
      partitions    = optional(list(string), [])
    })), {})

    # Logical volumes
    logical_volumes = optional(map(object({
      name           = string
      volume_group   = string
      size_gigabytes = number
      fs_type        = optional(string)
      mount_point    = optional(string)
      mount_options  = optional(string)
    })), {})
  }))
  default = {}
}

variable "nodes" {
  description = "Map of nodes with their storage profile and device mappings"
  type = map(object({
    hostname        = string
    storage_profile = optional(string) # Reference to storage_profiles key

    # Device mappings: map profile device roles to actual devices
    # Key is the device role from profile (e.g., "disk1"), value is device identification
    devices = optional(map(object({
      name           = string
      id_path        = optional(string)
      model          = optional(string)
      serial         = optional(string)
      size_gigabytes = optional(number, 0)
      block_size     = optional(number)
      is_boot_device = optional(bool, false)
      tags           = optional(list(string), [])
    })), {})

    # Legacy inline configuration (for backward compatibility)
    # Block devices to configure
    # Either id_path OR (model + serial) must be provided
    block_devices = optional(map(object({
      name           = string
      id_path        = optional(string)
      model          = optional(string)
      serial         = optional(string)
      size_gigabytes = optional(number, 0) # 0 = use existing size
      block_size     = optional(number)
      is_boot_device = optional(bool, false)
      tags           = optional(list(string), [])
      partitions = optional(list(object({
        size_gigabytes = number
        fs_type        = optional(string)
        label          = optional(string)
        bootable       = optional(bool)
        mount_point    = optional(string)
        mount_options  = optional(string)
        tags           = optional(list(string), [])
      })), [])
    })), {})

    # RAID arrays
    # - partitions can be: IDs (e.g., [123, 124]) or references (e.g., ["sda.0", "sdb.0"])
    # - or use tags like "raid:<name>" for auto-discovery
    raids = optional(map(object({
      name             = string
      level            = number
      block_devices    = optional(list(string), [])
      partitions       = optional(list(string), [])
      spare_devices    = optional(list(string), [])
      spare_partitions = optional(list(string), [])
      fs_type          = optional(string)
      mount_point      = optional(string)
      mount_options    = optional(string)
    })), {})

    # Volume groups
    # - partitions can be: IDs (e.g., [123, 124]) or references (e.g., ["sda.0", "sdb.0"])
    # - or use tags like "vg:<name>" for auto-discovery
    volume_groups = optional(map(object({
      name          = string
      block_devices = optional(list(string), [])
      partitions    = optional(list(string), [])
    })), {})

    # Logical volumes
    logical_volumes = optional(map(object({
      name           = string
      volume_group   = string
      size_gigabytes = number
      fs_type        = optional(string)
      mount_point    = optional(string)
      mount_options  = optional(string)
    })), {})
  }))
}
