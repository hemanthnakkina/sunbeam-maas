# MAAS Configure Networking Module

This module manages multiple MAAS networking resources including spaces, fabrics, VLANs, subnets, and IP ranges.

## Features

- Create multiple spaces for network grouping
- Create multiple fabrics
- Configure multiple VLANs with space association, custom MTU and DHCP settings
- Create multiple subnets with gateway, DNS, and management settings
- Define multiple IP ranges (reserved, dynamic) for each subnet
- Support for both new and existing spaces, fabrics, and VLANs

## Usage

### Example - Multiple Spaces, Fabrics, VLANs, and Subnets

```hcl
module "network" {
  source = "../../modules/maas-networking"

  # Create spaces
  spaces = {
    "prod-space" = {
      name = "production"
    }
    "mgmt-space" = {
      name = "management"
    }
  }

  # Create fabrics
  fabrics = {
    "prod" = {
      name = "prod-fabric"
    }
    "mgmt" = {
      name = "mgmt-fabric"
    }
  }

  # Create VLANs
  vlans = {
    "prod-vlan-10" = {
      vid          = 10
      name         = "prod-vlan-10"
      description  = "Production VLAN 10"
      fabric_name  = "prod-fabric"
      space_name   = "production"
      mtu          = 1500
      dhcp_on      = true
    }
    "prod-vlan-20" = {
      vid          = 20
      name         = "prod-vlan-20"
      description  = "Production VLAN 20"
      fabric_name  = "prod-fabric"
      space_name   = "production"
    }
    "mgmt-vlan" = {
      vid          = 100
      name         = "mgmt-vlan"
      fabric_name  = "mgmt-fabric"
      space_name   = "management"
      dhcp_on      = true
    }
  }

  # Create subnets
  subnets = {
    "prod-subnet-10" = {
      cidr        = "10.0.10.0/24"
      name        = "prod-subnet-10"
      vlan_id     = maas_vlan.vlan["prod-vlan-10"].id
      gateway_ip  = "10.0.10.1"
      dns_servers = ["8.8.8.8", "8.8.4.4"]
      ip_ranges = {
        "dynamic" = {
          type     = "dynamic"
          start_ip = "10.0.10.100"
          end_ip   = "10.0.10.200"
          comment  = "DHCP pool"
        }
        "reserved" = {
          type     = "reserved"
          start_ip = "10.0.10.10"
          end_ip   = "10.0.10.50"
          comment  = "Infrastructure"
        }
      }
    }
    "prod-subnet-20" = {
      cidr        = "10.0.20.0/24"
      name        = "prod-subnet-20"
      vlan_id     = maas_vlan.vlan["prod-vlan-20"].id
      gateway_ip  = "10.0.20.1"
      dns_servers = ["8.8.8.8"]
      ip_ranges = {
        "storage" = {
          type     = "reserved"
          start_ip = "10.0.20.10"
          end_ip   = "10.0.20.100"
        }
      }
    }
    "mgmt-subnet" = {
      cidr        = "192.168.1.0/24"
      name        = "mgmt-subnet"
      vlan_id     = maas_vlan.vlan["mgmt-vlan"].id
      gateway_ip  = "192.168.1.1"
      ip_ranges = {
        "dynamic" = {
          type     = "dynamic"
          start_ip = "192.168.1.100"
          end_ip   = "192.168.1.200"
        }
      }
    }
  }
}
```

### Example - Use Existing Space and Fabric

```hcl
module "network" {
  source = "../../modules/maas-networking"

  # Create VLANs and subnets referencing existing resources by ID

  # Subnets using existing VLAN ID
  subnets = {
    "existing-subnet" = {
      cidr       = "10.0.30.0/24"
      name       = "existing-subnet"
      vlan_id    = 10
      gateway_ip = "10.0.30.1"
      ip_ranges  = {}
    }
  }
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| spaces | Map of spaces to create | map(object) | no |
| fabrics | Map of fabrics to create | map(object) | no |
| vlans | Map of VLANs to create | map(object) | no |
| subnets | Map of subnets to create | map(object) | no |

## Outputs

| Name | Description |
|------|-------------|
| spaces | Map of created spaces with IDs |
| fabrics | Map of created fabrics with IDs |
| vlans | Map of created VLANs with IDs and VIDs |
| subnets | Map of created subnets with IDs and CIDRs |
| ip_ranges | Map of created IP ranges by subnet |

## Resources Created

- `maas_space` - Spaces for network grouping (one per spaces map entry)
- `maas_fabric` - Fabrics (one per fabrics map entry)
- `maas_vlan` - VLANs with space association (one per vlans map entry)
- `maas_subnet` - Subnets (one per subnets map entry)
- `maas_subnet_ip_range` - IP ranges within subnets

## Network Hierarchy

MAAS networking resources follow this hierarchy:

```
Space (logical grouping)
├── VLAN 1 (in Fabric 1)
│   ├── Subnet A
│   │   ├── IP Range 1
│   │   └── IP Range 2
│   └── Subnet B
└── VLAN 2 (in Fabric 2)
    └── Subnet C
```

Spaces provide logical network grouping for isolation and routing. VLANs belong to fabrics (physical infrastructure) and can be associated with spaces. Subnets are configured within VLANs, and IP ranges define allocation pools within subnets.
- `maas_subnet_ip_range` - IP ranges (one per range defined in each subnet)
