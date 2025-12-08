# MAAS Configure Networking Module
# Manages MAAS networking resources: spaces, fabrics, VLANs, and subnets

# Flatten the hierarchical structure for easier resource creation
locals {
  # Flatten VLANs from fabrics
  vlans_flat = flatten([
    for fabric_name, fabric in var.fabrics : [
      for vlan_idx, vlan in fabric.vlans : {
        key         = "${fabric_name}-${vlan.vid}"
        fabric_name = fabric_name
        vid         = vlan.vid
        space       = try(vlan.space, null)
        dhcp_on     = try(vlan.dhcp_on, false)
        mtu         = try(vlan.mtu, 1500)
        subnets     = vlan.subnets
      }
    ]
  ])

  # Flatten subnets from VLANs
  subnets_flat = flatten([
    for vlan in local.vlans_flat : [
      for subnet_name, subnet in vlan.subnets : {
        key         = "${vlan.key}-${subnet_name}"
        vlan_key    = vlan.key
        name        = subnet_name
        cidr        = subnet.cidr
        gateway_ip  = try(subnet.gateway_ip, null)
        dns_servers = try(subnet.dns_servers, [])
        reserved    = try(subnet.reserved, {})
      }
    ]
  ])

  # Flatten IP ranges from subnets
  ip_ranges_flat = flatten([
    for subnet in local.subnets_flat : [
      for range_name, range in subnet.reserved : {
        key        = "${subnet.key}-${range_name}"
        subnet_key = subnet.key
        name       = range_name
        type       = range.type != null ? range.type : "reserved"
        start_ip   = range.start_ip
        end_ip     = range.end_ip
      }
    ]
  ])

  # Convert flattened lists to maps for for_each
  vlans_map     = { for vlan in local.vlans_flat : vlan.key => vlan }
  subnets_map   = { for subnet in local.subnets_flat : subnet.key => subnet }
  ip_ranges_map = { for range in local.ip_ranges_flat : range.key => range }
}

# Space resources
resource "maas_space" "space" {
  for_each = var.spaces

  name = each.key
}

# Fabric resources
resource "maas_fabric" "fabric" {
  for_each = var.fabrics

  name = each.key
}

# VLAN resources
resource "maas_vlan" "vlan" {
  for_each = local.vlans_map

  fabric  = maas_fabric.fabric[each.value.fabric_name].id
  vid     = each.value.vid
  name    = "${each.value.fabric_name}-${each.value.vid}"
  mtu     = each.value.mtu
  dhcp_on = each.value.dhcp_on
  space   = each.value.space
}

# Subnet resources
resource "maas_subnet" "subnet" {
  for_each = local.subnets_map

  cidr        = each.value.cidr
  fabric      = maas_vlan.vlan[each.value.vlan_key].fabric
  vlan        = maas_vlan.vlan[each.value.vlan_key].id
  name        = each.value.name
  gateway_ip  = each.value.gateway_ip
  dns_servers = each.value.dns_servers
  allow_dns   = true
  allow_proxy = true
  rdns_mode   = 2
}

# IP ranges for subnets
resource "maas_subnet_ip_range" "ip_range" {
  for_each = local.ip_ranges_map

  subnet   = maas_subnet.subnet[each.value.subnet_key].id
  type     = each.value.type
  start_ip = each.value.start_ip
  end_ip   = each.value.end_ip
  comment  = each.value.name
}
