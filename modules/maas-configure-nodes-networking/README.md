# maas-configure-nodes-networking

This module configures network interfaces on MAAS machines. It supports:
- Physical interfaces
- Bond interfaces
- Bridge interfaces
- VLAN interfaces
- Network interface links (IP assignments)
- **Network profiles** for reducing configuration duplication

## Features

- Configure multiple machines with different network setups
- Support for physical, bond, bridge, and VLAN interfaces
- Flexible interface link configuration (static, DHCP, auto)
- **Network profiles** to define reusable configurations
- Node-level overrides for MAC addresses and IP addresses
- Hierarchical configuration structure

## Usage

### With Network Profiles (Recommended)

```hcl
module "configure_nodes" {
  source = "../../modules/maas-configure-nodes-networking"

  # Define reusable network profiles
  network_profiles = {
    "hyperconverged" = {
      physical_interfaces = {
        "eth0" = {
          tags    = ["mgmt"]
          vlan_id = 10
          mtu     = 1500
        }
      }
      
      bond_interfaces = {
        "bond0" = {
          name       = "bond0"
          parents    = ["eth1", "eth2"]
          bond_mode  = "802.3ad"
        }
      }
      
      interface_links = {
        "eth0-mgmt" = {
          network_interface = "eth0"
          subnet_id         = "subnet-123"
          mode              = "STATIC"
          default_gateway   = true
        }
      }
    }
  }

  # Apply profiles to nodes - only specify MACs and IPs
  nodes = {
    "node1.maas" = {
      network_profile = "hyperconverged"
      
      physical_interfaces = {
        "eth0" = {
          mac_address = "00:11:22:33:44:55"
        }
        "eth1" = {
          mac_address = "00:11:22:33:44:66"
        }
        "eth2" = {
          mac_address = "00:11:22:33:44:77"
        }
      }
      
      static_ip_addresses = {
        "eth0-ip" = {
          interface_name = "eth0"
          subnet_id      = "subnet-123"
          ip_address     = "10.0.1.10"
        }
      }
    }
    
    "node2.maas" = {
      network_profile = "hyperconverged"
      
      physical_interfaces = {
        "eth0" = {
          mac_address = "00:11:22:33:55:55"
        }
        "eth1" = {
          mac_address = "00:11:22:33:55:66"
        }
        "eth2" = {
          mac_address = "00:11:22:33:55:77"
        }
      }
      
      static_ip_addresses = {
        "eth0-ip" = {
          interface_name = "eth0"
          subnet_id      = "subnet-123"
          ip_address     = "10.0.1.11"
        }
      }
    }
  }
}
```

### Without Network Profiles

```hcl
module "configure_nodes" {
  source = "../../modules/maas-configure-nodes-networking"

  nodes = {
    "node1.maas" = {  # Map key is the machine hostname in MAAS
      physical_interfaces = {
        "eth0" = {
          mac_address = "00:11:22:33:44:55"
          name        = "eth0"
          tags        = ["physical"]
          vlan_id     = 10
        }
      }
      
      bond_interfaces = {
        "bond0" = {
          name       = "bond0"
          parents    = ["eth1", "eth2"]
          bond_mode  = "802.3ad"
          vlan_id    = 10
        }
      }
      
      bridge_interfaces = {
        "br0" = {
          name        = "br0"
          parent      = "eth0"
          bridge_type = "standard"
          bridge_stp  = false
          vlan_id     = 10
        }
      }
      
      vlan_interfaces = {
        "eth0.100" = {
          parent  = "eth0"
          vlan_id = 100
          fabric  = 1  # Optional: specify fabric ID
          tags    = ["vlan"]
        }
      }
      
      interface_links = {
        "eth0-link" = {
          interface_name = "eth0"
          subnet_id      = "subnet-123"
          mode           = "STATIC"
          ip_address     = "10.0.1.10"
        }
      }
    }
  }
}
```

## Input Variables

### network_profiles

Optional map of reusable network profiles. Each profile can define the same interface types as nodes (physical, bond, bridge, VLAN, links) but without MAC addresses. Use profiles to avoid duplicating configuration across multiple nodes.

**Benefits:**
- Define common network topologies once
- Nodes only specify unique values (MAC addresses, IP addresses)
- Easy to manage large deployments with similar configurations

### nodes

A map of node configurations where the **map key is the machine hostname** in MAAS. Each node can have:

- `network_profile` (optional): Name of a network profile to use as base configuration
- `physical_interfaces` (optional): Map of physical interface configurations
- `bond_interfaces` (optional): Map of bond interface configurations
- `bridge_interfaces` (optional): Map of bridge interface configurations
- `vlan_interfaces` (optional): Map of VLAN interface configurations
- `interface_links` (optional): Map of interface link (IP assignment) configurations

#### physical_interfaces

Each physical interface supports:
- `mac_address` (required): MAC address of the interface
- `name` (optional): Name for the interface
- `tags` (optional): List of tags
- `vlan_id` (optional): VLAN ID to assign
- `mtu` (optional): MTU size
- `accept_ra` (optional): Accept router advertisements (true/false)

#### bond_interfaces

Each bond interface supports:
- `name` (required): Name for the bond
- `parents` (required): List of interface names to bond
- `bond_mode` (optional): Bond mode (balance-rr, active-backup, balance-xor, broadcast, 802.3ad, balance-tlb, balance-alb)
- `bond_miimon` (optional): MII monitoring interval
- `bond_downdelay` (optional): Down delay
- `bond_updelay` (optional): Up delay
- `bond_lacp_rate` (optional): LACP rate (slow/fast)
- `bond_xmit_hash_policy` (optional): Transmit hash policy
- `vlan_id` (optional): VLAN ID to assign
- `tags` (optional): List of tags
- `mtu` (optional): MTU size
- `accept_ra` (optional): Accept router advertisements

#### bridge_interfaces

Each bridge interface supports:
- `name` (required): Name for the bridge
- `parent` (optional): Parent interface name (optional, can create a bridge without parent)
- `bridge_type` (optional): Bridge type - "standard" (default) or "ovs" (Open vSwitch)
- `bridge_stp` (optional): Enable Spanning Tree Protocol (true/false)
- `bridge_fd` (optional): Bridge forward delay
- `vlan_id` (optional): VLAN ID to assign
- `tags` (optional): List of tags
- `mtu` (optional): MTU size
- `accept_ra` (optional): Accept router advertisements

#### vlan_interfaces

Each VLAN interface supports:
- `parent` (required): Name of the parent interface
- `vlan_id` (required): VLAN ID
- `fabric` (optional): Fabric ID for the VLAN
- `tags` (optional): List of tags
- `mtu` (optional): MTU size
- `accept_ra` (optional): Accept router advertisements

#### interface_links

Each interface link supports:
- `network_interface` (required): Name of the interface to link
- `subnet_id` (required): Subnet ID to assign
- `mode` (required): Link mode (AUTO, DHCP, STATIC, LINK_UP)
- `ip_address` (optional): IP address (required for STATIC mode)
- `default_gateway` (optional): Set as default gateway (true/false)

#### static_ip_addresses

Optional map to define static IP addresses for interfaces. Useful when using network profiles to avoid embedding IPs in interface definitions. Each entry supports:
- `interface_name` (required): Name of the interface to assign the IP to
- `subnet_id` (required): Subnet ID for the IP address
- `ip_address` (required): The static IP address to assign

**Note:** When using network profiles with STATIC mode links, the module will automatically match static_ip_addresses to the corresponding interface_links by subnet_id.

## Outputs

- `physical_interfaces`: Map of created physical interface IDs
- `bond_interfaces`: Map of created bond interface IDs
- `bridge_interfaces`: Map of created bridge interface IDs
- `vlan_interfaces`: Map of created VLAN interface IDs
- `interface_links`: Map of created interface link IDs

## Example Configurations

### Simple Physical Interface with Static IP

```hcl
nodes = {
  "server1.maas" = {  # Machine hostname in MAAS
    physical_interfaces = {
      "eth0" = {
        mac_address = "00:11:22:33:44:55"
        name        = "eth0"
      }
    }
    
    interface_links = {
      "eth0-static" = {
        network_interface = "eth0"
        subnet_id         = "subnet-123"
        mode              = "STATIC"
        ip_address        = "10.0.1.10"
      }
    }
  }
}
```

### Bond Interface

```hcl
nodes = {
  "server1.maas" = {
    bond_interfaces = {
      "bond0" = {
        name       = "bond0"
        parents    = ["eth0", "eth1"]
        bond_mode  = "802.3ad"
        bond_lacp_rate = "fast"
      }
    }
    
    interface_links = {
      "bond0-dhcp" = {
        network_interface = "bond0"
        subnet_id         = "subnet-123"
        mode              = "DHCP"
      }
    }
  }
}
```

### Bridge Interface

```hcl
nodes = {
  "server1.maas" = {
    physical_interfaces = {
      "eth0" = {
        mac_address = "00:11:22:33:44:55"
        name        = "eth0"
      }
    }
    
    bridge_interfaces = {
      "br0" = {
        name        = "br0"
        parent      = "eth0"
        bridge_type = "standard"
        bridge_stp  = false
        bridge_fd   = 15
      }
    }
    
    interface_links = {
      "br0-static" = {
        network_interface = "br0"
        subnet_id         = "subnet-123"
        mode              = "STATIC"
        ip_address        = "10.0.1.15"
      }
    }
  }
}
```

### VLAN Interface

```hcl
nodes = {
  "server1.maas" = {
    vlan_interfaces = {
      "eth0.100" = {
        parent  = "eth0"
        vlan_id = 100
        fabric  = 1
      }
    }
    
    interface_links = {
      "vlan100-auto" = {
        network_interface = "eth0.100"
        subnet_id         = "subnet-456"
        mode              = "AUTO"
      }
    }
  }
}
```

## Notes

- The module uses a data source to lookup machine system IDs by hostname
- Machines must already exist in MAAS (use `maas-enlist-machines` module first)
- Physical interfaces are identified by MAC address
- Bond, bridge, and VLAN interfaces are created on top of existing interfaces
- Bridges can be created with or without a parent interface
- **Network profiles are merged with node configs**: profile provides defaults, node provides MACs and IPs
- When using profiles, nodes can still override any profile setting by specifying it explicitly
- Interface links assign IP configurations to interfaces
- Use `mode = "STATIC"` for static IP assignment (requires `ip_address`)
- Use `mode = "DHCP"` for DHCP configuration
- Use `mode = "AUTO"` for automatic IP assignment from subnet
- Use `mode = "LINK_UP"` to bring interface up without IP assignment
