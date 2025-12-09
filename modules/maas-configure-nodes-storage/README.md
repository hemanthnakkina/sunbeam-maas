# MAAS Configure Nodes Storage

Terraform module for configuring storage on MAAS machines, including block devices, RAID arrays, LVM volume groups, and logical volumes.

## Features

- Configure block devices by id_path or model/serial
- Create partitions directly within block devices
- **Tag-based partition discovery**: Automatically include partitions tagged with `raid:<raid_name>` or `vg:<vg_name>`
- Create RAID arrays from block devices or partition IDs
- Create LVM volume groups from block devices or partition IDs
- Create logical volumes with filesystem configuration
- Direct filesystem configuration on RAID and logical volumes

## Important Notes

**Partitions**: You can create partitions directly within block device definitions. Partitions can be tagged and automatically discovered by RAID arrays or volume groups using tags like `raid:<raid_name>`, `vg:<vg_name>`, or `raid-spare:<raid_name>`.

**Block Devices**: This module references existing block devices. Each block device must specify either `id_path` OR (`model` + `serial`) to identify the device.

## Usage

```hcl
module "storage" {
  source = "../../../modules/maas-configure-nodes-storage"

  machines = {
    node1 = {
      hostname = "maas-node-1"
      
      block_devices = {
        sda = {
          name    = "sda"
          id_path = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0"
          tags    = ["storage"]
        }
        sdb = {
          name    = "sdb"
          id_path = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1"
        }
      }

      raids = {
        md0 = {
          name          = "md0"
          level         = 1
          block_devices = ["sda", "sdb"]
          fs_type       = "ext4"
          mount_point   = "/mnt/raid"
        }
      }

      volume_groups = {
        vg0 = {
          name          = "vg0"
          block_devices = ["sda"]
        }
      }

      logical_volumes = {
        lv_data = {
          name           = "lv-data"
          volume_group   = "vg0"
          size_gigabytes = 100
          fs_type        = "xfs"
          mount_point    = "/data"
        }
      }
    }
  }
}
```

### Example with Partition IDs

```hcl
machines = {
  node1 = {
    hostname = "maas-node-1"
    
    raids = {
      md0 = {
        name       = "md0"
        level      = 5
        partitions = [123, 124, 125]  # Pre-existing partition IDs
        fs_type    = "ext4"
        mount_point = "/mnt/raid5"
      }
    }

    volume_groups = {
      vg0 = {
        name       = "vg0"
        partitions = [126, 127]  # Pre-existing partition IDs
      }
    }
  }
}
```

### Example with Tag-Based Partition Discovery

```hcl
machines = {
  node1 = {
    hostname = "maas-node-1"
    
    block_devices = {
      sda = {
        name           = "sda"
        id_path        = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0"
        size_gigabytes = 500
        partitions = [
          {
            size_gigabytes = 200
            tags           = ["raid:md0"]  # Auto-discovered by RAID md0
          },
          {
            size_gigabytes = 100
            tags           = ["vg:vg_data"]  # Auto-discovered by VG vg_data
          }
        ]
      }
      sdb = {
        name           = "sdb"
        id_path        = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1"
        size_gigabytes = 500
        partitions = [
          {
            size_gigabytes = 200
            tags           = ["raid:md0"]  # Auto-discovered by RAID md0
          },
          {
            size_gigabytes = 200
            tags           = ["raid-spare:md0"]  # Auto-discovered as spare for md0
          }
        ]
      }
    }

    raids = {
      md0 = {
        name        = "md0"
        level       = 1
        # Partitions tagged with "raid:md0" are automatically included
        fs_type     = "ext4"
        mount_point = "/mnt/raid"
      }
    }

    volume_groups = {
      vg_data = {
        name = "vg-data"
        # Partitions tagged with "vg:vg_data" are automatically included
      }
    }
  }
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| machines | Map of machines with storage configuration | map(object) | yes |

### Machine Object Structure

- `hostname`: Machine hostname (string, required)
- `block_devices`: Map of block devices (optional)
  - `name`: Device name (string, required)
  - `id_path`: Device ID path (string, required if model not set)
  - `model`: Device model (string, optional)
  - `serial`: Device serial (string, optional)
  - `tags`: Device tags (list(string), optional)
- `raids`: Map of RAID arrays (optional)
  - `name`: RAID name (string, required)
  - `level`: RAID level 0/1/5/6/10 (number, required)
  - `block_devices`: List of block device keys (list(string), optional)
  - `partitions`: List of partition IDs (list(string), optional)
  - `spare_devices`: List of spare block device keys (list(string), optional)
  - `spare_partitions`: List of spare partition IDs (list(string), optional)
  - `fs_type`: Filesystem type (string, optional)
  - `mount_point`: Mount point (string, optional)
  - `mount_options`: Mount options (string, optional)
- `volume_groups`: Map of LVM volume groups (optional)
  - `name`: VG name (string, required)
  - `block_devices`: List of block device keys (list(string), optional)
  - `partitions`: List of partition IDs (list(string), optional)
- `logical_volumes`: Map of logical volumes (optional)
  - `name`: LV name (string, required)
  - `volume_group`: VG key from volume_groups map (string, required)
  - `size_gigabytes`: LV size in GB (number, required)
  - `fs_type`: Filesystem type (string, optional)
  - `mount_point`: Mount point (string, optional)
  - `mount_options`: Mount options (string, optional)

## Outputs

| Name | Description |
|------|-------------|
| block_devices | Configured block devices |
| raids | Configured RAID arrays |
| volume_groups | Configured volume groups |
| logical_volumes | Configured logical volumes |

## Storage Workflow

1. **Block Devices**: Reference existing devices by `id_path` or `model`
2. **RAID Arrays**: Created from block devices or partition IDs, can have filesystem
3. **Volume Groups**: Created from block devices or partition IDs
4. **Logical Volumes**: Created within volume groups, can have filesystem

## RAID Levels

- `0`: Striping (no redundancy)
- `1`: Mirroring (2+ devices)
- `5`: Striping with parity (3+ devices)
- `6`: Striping with double parity (4+ devices)
- `10`: Mirrored striping (4+ devices)

## Requirements

- Terraform >= 1.0
- MAAS provider >= 2.0
- Pre-existing partitions for partition-based configurations
