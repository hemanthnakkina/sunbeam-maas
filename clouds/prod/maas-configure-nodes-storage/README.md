# MAAS Configure Nodes Storage Unit

This unit configures storage on MAAS machines including block devices, partitions, RAID arrays, LVM volume groups, and logical volumes.

## Purpose

Configure storage layouts on MAAS machines using either:
- Storage profiles (reusable configurations)
- Inline storage definitions

## Dependencies

- `maas-enlist-machines`: Machines must be enlisted
- `maas-configure-nodes`: Node networking configuration must be complete

## Configuration Files

- `storage_profiles.tfvars`: Reusable storage profile definitions (optional)
- `storage.tfvars`: Machine-to-profile mappings and device identification

## Usage

### With Storage Profiles

Create `storage_profiles.tfvars`:
```hcl
storage_profiles = {
  compute-standard = {
    partitions = {
      disk1 = [{size_gigabytes = 50, fs_type = "ext4", mount_point = "/boot"}]
      disk2 = [{size_gigabytes = 1000, tags = ["vg:vg_data"]}]
    }
    volume_groups = {
      vg_data = {name = "vg-data"}
    }
    logical_volumes = {
      lv_var = {
        name = "lv-var"
        volume_group = "vg_data"
        size_gigabytes = 200
        fs_type = "xfs"
        mount_point = "/var"
      }
    }
  }
}
```

Create `storage.tfvars`:
```hcl
machines = {
  compute-01 = {
    hostname = "compute-node-01.maas"
    storage_profile = "compute-standard"
    devices = {
      disk1 = {
        name = "sda"
        id_path = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0"
        is_boot_device = true
      }
      disk2 = {
        name = "sdb"
        id_path = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1"
      }
    }
  }
}
```

### Without Profiles (Inline)

Create `storage.tfvars`:
```hcl
machines = {
  compute-01 = {
    hostname = "compute-node-01.maas"
    block_devices = {
      sda = {
        name = "sda"
        id_path = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0"
        partitions = [
          {
            size_gigabytes = 100
            fs_type = "ext4"
            mount_point = "/"
          }
        ]
      }
    }
  }
}
```

## Running

```bash
# Plan
terragrunt plan

# Apply
terragrunt apply

# Destroy
terragrunt destroy
```

## Features

- **Storage Profiles**: Define once, reuse across machines
- **Flexible Device Identification**: Use id_path, model+serial
- **Tag-based Partition Discovery**: Auto-include partitions with tags like `raid:<name>` or `vg:<name>`
- **RAID Support**: RAID 0, 1, 5, 6, 10 with spare devices
- **LVM Support**: Volume groups and logical volumes with filesystem configuration
- **RAID as VG Physical Volume**: Use RAID arrays in volume groups

## Examples

See module directory for complete examples:
- `modules/maas-configure-nodes-storage/storage.tfvars.example` - Inline configurations
- `modules/maas-configure-nodes-storage/storage-profiles.tfvars.example` - Profile-based configurations

Note: Do not create RAIDS and LVS without mount points due to bugs
https://github.com/canonical/terraform-provider-maas/issues/391
https://github.com/canonical/terraform-provider-maas/issues/392

