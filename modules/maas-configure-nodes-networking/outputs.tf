output "physical_interfaces" {
  description = "Map of physical interface IDs by node and interface key"
  value = {
    for key, iface in data.maas_network_interface_physical.interface :
    key => {
      id          = iface.id
      machine_id  = iface.machine
      mac_address = iface.mac_address
      name        = iface.name
    }
  }
}

output "bond_interfaces" {
  description = "Map of bond interface IDs by node and bond key"
  value = {
    for key, bond in maas_network_interface_bond.bond :
    key => {
      id         = bond.id
      machine_id = bond.machine
      name       = bond.name
      parents    = bond.parents
    }
  }
}

output "bridge_interfaces" {
  description = "Map of bridge interface IDs by node and bridge key"
  value = {
    for key, bridge in maas_network_interface_bridge.bridge :
    key => {
      id         = bridge.id
      machine_id = bridge.machine
      name       = bridge.name
      parent     = bridge.parent
    }
  }
}

output "vlan_interfaces" {
  description = "Map of VLAN interface IDs by node and VLAN key"
  value = {
    for key, vlan in maas_network_interface_vlan.vlan :
    key => {
      id         = vlan.id
      machine_id = vlan.machine
      parent     = vlan.parent
      vlan_id    = vlan.vlan
    }
  }
}

output "interface_links" {
  description = "Map of interface link IDs by node and link key"
  value = {
    for key, link in maas_network_interface_link.link :
    key => {
      id         = link.id
      machine_id = link.machine
      interface  = link.network_interface
      subnet_id  = link.subnet
      mode       = link.mode
      ip_address = link.ip_address
    }
  }
}

output "nodes_summary" {
  description = "Summary of configured nodes"
  value = {
    for node_key, node in var.nodes :
    node_key => {
      machine_name         = node_key
      machine_id           = local.machine_ids[node_key]
      physical_count       = length(node.physical_interfaces)
      bond_count           = length(node.bond_interfaces)
      bridge_count         = length(node.bridge_interfaces)
      vlan_count           = length(node.vlan_interfaces)
      interface_link_count = length(node.interface_links)
    }
  }
}
