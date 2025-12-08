# Data source to lookup machine system IDs by hostname
# The map key is used as the machine hostname
data "maas_machine" "machines" {
  for_each = var.nodes
  hostname = each.key
}

locals {
  # Create a map of machine names to system IDs
  machine_ids = {
    for node_key, node in var.nodes :
    node_key => data.maas_machine.machines[node_key].id
  }

  # Merge node-specific configs with network profile configs
  merged_nodes = {
    for node_key, node in var.nodes :
    node_key => {
      machine_id = local.machine_ids[node_key]

      # Merge physical interfaces: node provides MAC + optional overrides, profile provides the rest
      physical_interfaces = node.network_profile != null ? {
        for iface_key, node_iface in node.physical_interfaces :
        iface_key => merge(
          # Start with profile defaults
          try(var.network_profiles[node.network_profile].physical_interfaces[iface_key], {}),
          # Override with node-specific values (MAC is required, others optional)
          {
            mac_address = node_iface.mac_address
            name        = coalesce(node_iface.name, iface_key)
            tags        = node_iface.tags != null && length(node_iface.tags) > 0 ? node_iface.tags : null
            vlan_id     = node_iface.vlan_id
            mtu         = node_iface.mtu
            accept_ra   = node_iface.accept_ra
          }
        )
        } : {
        for iface_key, iface in node.physical_interfaces :
        iface_key => merge(iface, {
          name = coalesce(iface.name, iface_key)
        })
      }

      # Use profile's bond/bridge/vlan interfaces or node's own
      bond_interfaces = node.network_profile != null ? (
        try(var.network_profiles[node.network_profile].bond_interfaces, {})
      ) : node.bond_interfaces

      bridge_interfaces = node.network_profile != null ? (
        try(var.network_profiles[node.network_profile].bridge_interfaces, {})
      ) : node.bridge_interfaces

      vlan_interfaces = node.network_profile != null ? (
        try(var.network_profiles[node.network_profile].vlan_interfaces, {})
      ) : node.vlan_interfaces

      # Merge interface links: profile defines config, node provides IP addresses via static_ip_addresses
      interface_links = node.network_profile != null ? {
        for link_key, profile_link in try(var.network_profiles[node.network_profile].interface_links, {}) :
        link_key => merge(
          profile_link,
          # If this link has a static IP defined for the same subnet, use it
          profile_link.mode == "STATIC" ? {
            ip_address = try(
              [for ip_key, ip_config in node.static_ip_addresses :
                ip_config.ip_address if ip_config.subnet_id == profile_link.subnet_id
              ][0],
              null
            )
          } : {}
        )
      } : node.interface_links
    }
  }

  # Flatten physical interfaces for all nodes
  physical_interfaces = merge([
    for node_key, node in local.merged_nodes : {
      for iface_key, iface in node.physical_interfaces :
      "${node_key}-${iface_key}" => merge(iface, {
        node_key   = node_key
        machine_id = node.machine_id
      })
    }
  ]...)

  # Flatten bond interfaces for all nodes
  bond_interfaces = merge([
    for node_key, node in local.merged_nodes : {
      for bond_key, bond in node.bond_interfaces :
      "${node_key}-${bond_key}" => merge(bond, {
        node_key   = node_key
        machine_id = node.machine_id
      })
    }
  ]...)

  # Flatten bridge interfaces for all nodes
  bridge_interfaces = merge([
    for node_key, node in local.merged_nodes : {
      for bridge_key, bridge in node.bridge_interfaces :
      "${node_key}-${bridge_key}" => merge(bridge, {
        node_key   = node_key
        machine_id = node.machine_id
      })
    }
  ]...)

  # Flatten VLAN interfaces for all nodes
  vlan_interfaces = merge([
    for node_key, node in local.merged_nodes : {
      for vlan_key, vlan in node.vlan_interfaces :
      "${node_key}-${vlan_key}" => merge(vlan, {
        name       = coalesce(vlan.name, vlan_key)
        node_key   = node_key
        machine_id = node.machine_id
      })
    }
  ]...)

  # Flatten interface links for all nodes
  interface_links = merge([
    for node_key, node in local.merged_nodes : {
      for link_key, link in node.interface_links :
      "${node_key}-${link_key}" => merge(link, {
        node_key   = node_key
        machine_id = node.machine_id
      })
    }
  ]...)
}

# Physical Network Interfaces - Use data source to reference existing interfaces
data "maas_network_interface_physical" "interface" {
  for_each = local.physical_interfaces

  machine = each.value.machine_id
  name    = each.value.name
}

# Bond Interfaces
resource "maas_network_interface_bond" "bond" {
  for_each = local.bond_interfaces

  machine               = each.value.machine_id
  name                  = each.value.name
  parents               = each.value.parents
  bond_mode             = each.value.bond_mode
  bond_miimon           = each.value.bond_miimon
  bond_downdelay        = each.value.bond_downdelay
  bond_updelay          = each.value.bond_updelay
  bond_lacp_rate        = each.value.bond_lacp_rate
  bond_xmit_hash_policy = each.value.bond_xmit_hash_policy
  vlan                  = each.value.vlan_id
  tags                  = each.value.tags
  mtu                   = each.value.mtu

  # Bond creation depends on physical interfaces existing
  depends_on = [data.maas_network_interface_physical.interface]
}

# Bridge Interfaces
resource "maas_network_interface_bridge" "bridge" {
  for_each = local.bridge_interfaces

  machine     = each.value.machine_id
  name        = each.value.name
  parent      = each.value.parent
  bridge_type = each.value.bridge_type
  bridge_stp  = each.value.bridge_stp
  bridge_fd   = each.value.bridge_fd
  vlan        = each.value.vlan_id
  tags        = each.value.tags
  mtu         = each.value.mtu

  # Bridge creation depends on parent interfaces existing
  depends_on = [
    data.maas_network_interface_physical.interface,
    maas_network_interface_bond.bond
  ]
}

# VLAN Interfaces
resource "maas_network_interface_vlan" "vlan" {
  for_each = local.vlan_interfaces

  machine = each.value.machine_id
  parent  = each.value.parent
  vlan    = each.value.vlan_id
  fabric  = each.value.fabric
  tags    = each.value.tags
  mtu     = each.value.mtu

  # VLAN creation depends on parent interfaces existing
  depends_on = [
    data.maas_network_interface_physical.interface,
    maas_network_interface_bond.bond,
    maas_network_interface_bridge.bridge
  ]
}

# Interface Links (IP Configuration)
resource "maas_network_interface_link" "link" {
  for_each = local.interface_links

  machine           = each.value.machine_id
  network_interface = each.value.network_interface
  subnet            = each.value.subnet_id
  mode              = each.value.mode
  ip_address        = try(each.value.ip_address, null)
  default_gateway   = each.value.default_gateway

  # Links depend on all interfaces being created
  depends_on = [
    data.maas_network_interface_physical.interface,
    maas_network_interface_bond.bond,
    maas_network_interface_bridge.bridge,
    maas_network_interface_vlan.vlan
  ]
}
