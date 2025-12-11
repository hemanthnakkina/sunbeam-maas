# MAAS Compose VMs Module

This module manages virtual machines on MAAS VM hosts using the `maas_vm_host_machine` resource.

## Features

- Create multiple VM instances from a single configuration
- Support for multiple VM configurations with different specs
- Per-VM zone and pool configuration
- Automatic hostname generation with zone prefixes
- Configurable storage disks
- Configurable network interfaces
- Automatic tag assignment to VMs
- Flexible VM host assignment per configuration

## Usage

```hcl
module "compose_vms" {
  source = "../../modules/maas-compose-vms"

  vm_configurations = {
    # Key is just a label for grouping VMs
    web_servers = {
      vm_host         = ["abc123"]  # VM host system ID list: host[0] -> first VM, host[1] -> second, etc.
      hostname_prefix = "web"
      zone            = ["az-1"]  # Zone list: zone[0] -> first VM, zone[1] -> second, etc.
      pool            = "compute"
      count           = 3
      cores           = 4
      memory          = 8192
      tags            = ["web", "production"]
      storage_disks = [
        {
          size_gigabytes = 50
          pool           = "default"
        }
      ]
      network = [
        {
          name        = "eth0"
          subnet_cidr = "10.0.1.0/24"
        }
      ]
    }
    db_servers = {
      vm_host         = ["def456", "def457"]  # Example: db-0 -> def456, db-1 -> def457
      hostname_prefix = "db"
      zone            = ["az-2", "az-3"]  # Example: db-0 -> az-2, db-1 -> az-3
      pool            = "database"
      count           = 2
      cores           = 8
      memory          = 16384
      tags            = ["database", "postgresql"]
      storage_disks = [
        {
          size_gigabytes = 100
          pool           = "fast"
        },
        {
          size_gigabytes = 500
          pool           = "data"
        }
      ]
      network = [
        {
          name        = "eth0"
          subnet_cidr = "10.0.2.0/24"
        }
      ]
    }
  }
}
```

This example will create:
- 3 web servers on VM host abc123: az-1-web-0, az-1-web-1, az-1-web-2 (4 cores, 8GB RAM each)
- 2 database servers on VM host def456: az-2-db-0, az-2-db-1 (8 cores, 16GB RAM each)

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| vm_configurations | Map of VM configurations (key = VM host system ID) | map(object) | yes |

### vm_configurations Object

| Field | Description | Type | Required |
|-------|-------------|------|----------|
| vm_host | VM host system ID list; host[0] -> first VM, host[1] -> second, etc. | list(string) | no |
| hostname_prefix | Prefix for VM hostnames (uses key if omitted) | string | no |
| zone | Availability zone (prefixed to hostname if set) | string | no |
| pool | Resource pool | string | no |
| count | Number of instances to create | number | yes |
| cores | Number of CPU cores | number | yes |
| pinned_cores | List of pinned CPU cores | list(number) | no |
| memory | Memory in MB | number | yes |
| storage_disks | List of storage disk configurations | list(object) | no |
| network | List of network interface configurations | list(object) | no |
| tags | List of tags to apply to VMs | list(string) | no |

## Outputs

| Name | Description |
|------|-------------|
| vm_machines | Map of all created VMs with details |
| vm_hostnames | List of all VM hostnames |
| vm_system_ids | Map of VM keys to system IDs |
