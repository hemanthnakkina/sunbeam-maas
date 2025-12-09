# maas-configure-nodes Unit

This unit configures network interfaces on MAAS machines using the `maas-configure-nodes-networking` module.

## Dependencies

This unit has dependencies on:
1. **maas-enlist-machines**: Machines must be enlisted before configuring their network interfaces
2. **maas-configure-networking**: Network topology (fabrics, VLANs, subnets) must be created first

## Configuration

The unit uses two JSON configuration files:

### network_profiles.tfvars.json

Defines reusable network profiles that specify the network topology:
- Physical interface configurations (tags, VLANs, MTU)
- Bond interface definitions
- Bridge interface definitions
- VLAN interface definitions
- Interface link configurations (how interfaces connect to subnets)

**Example profiles:**
- `hyperconverged`: 3 NICs with bonding and VLAN for storage
- `compute`: Single NIC with OVS bridge for external network

### nodes.tfvars.json

Defines individual nodes and their unique configurations:
- Machine hostname (map key)
- Network profile reference
- MAC addresses for each physical interface
- Static IP addresses for STATIC mode links

The nodes inherit the network topology from the profile and only specify:
- MAC addresses (required for physical interfaces)
- Static IP addresses (for interfaces using STATIC mode)

## Usage

### Prerequisites

1. Enlist machines first:
   ```bash
   cd ../maas-enlist-machines
   terragrunt apply
   ```

2. Configure networking:
   ```bash
   cd ../maas-configure-networking
   terragrunt apply
   ```

### Deploy Network Configuration

```bash
cd maas-configure-nodes
terragrunt apply
```

### Update Configuration

1. Edit `network_profiles.tfvars.json` to modify network topologies
2. Edit `nodes.tfvars.json` to add/update nodes
3. Run `terragrunt apply`

## Configuration Structure

### Adding a New Node

To add a new node to an existing profile:

```json
{
  "new-node.maas": {
    "network_profile": "hyperconverged",
    "physical_interfaces": {
      "eth0": {
        "mac_address": "52:54:00:04:00:01"
      },
      "eth1": {
        "mac_address": "52:54:00:04:00:02"
      },
      "eth2": {
        "mac_address": "52:54:00:04:00:03"
      }
    },
    "static_ip_addresses": {
      "eth0-ip": {
        "interface_name": "eth0",
        "subnet_id": "subnet-mgmt-id",
        "ip_address": "10.0.10.14"
      }
    }
  }
}
```

### Creating a New Network Profile

Add to `network_profiles.tfvars.json`:

```json
{
  "storage": {
    "physical_interfaces": {
      "eth0": {
        "tags": ["mgmt"],
        "mtu": 1500
      },
      "eth1": {
        "tags": ["storage"],
        "mtu": 9000
      }
    },
    "interface_links": {
      "eth0-mgmt": {
        "network_interface": "eth0",
        "subnet_id": "subnet-mgmt-id",
        "mode": "STATIC",
        "default_gateway": true
      },
      "eth1-storage": {
        "network_interface": "eth1",
        "subnet_id": "subnet-storage-id",
        "mode": "DHCP"
      }
    }
  }
}
```

## Network Profiles

### hyperconverged

Designed for compute nodes that also provide storage:
- **eth0**: Management network (VLAN 10, MTU 1500)
- **eth1 + eth2**: Bonded for data traffic (LACP, MTU 9000)
- **bond0.100**: VLAN for storage traffic

### compute

Designed for compute-only nodes with OVS:
- **eth0**: Base physical interface
- **br-ex**: Open vSwitch bridge on eth0 for external network

## Subnet IDs

Replace these placeholder subnet IDs with actual values from your MAAS deployment:
- `subnet-mgmt-id`: Management subnet
- `subnet-data-id`: Data/tenant network subnet
- `subnet-storage-id`: Storage network subnet

You can get subnet IDs from the `maas-configure-networking` unit outputs:
```bash
cd ../maas-configure-networking
terragrunt output subnet_ids
```

## Notes

- MAC addresses must be unique across all nodes
- Static IP addresses must be within the subnet range
- Machines must exist in MAAS before running this unit
- Network topology (subnets, VLANs, fabrics) must exist before configuring nodes
- Profile changes affect all nodes using that profile
- Individual nodes can override profile settings by specifying them explicitly
