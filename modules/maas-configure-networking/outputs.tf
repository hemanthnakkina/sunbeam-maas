# MAAS Configure Networking Module Outputs

output "spaces" {
  description = "Map of created spaces"
  value = {
    for k, v in maas_space.space : k => {
      id   = v.id
      name = v.name
    }
  }
}

output "fabrics" {
  description = "Map of created fabrics"
  value = {
    for k, v in maas_fabric.fabric : k => {
      id   = v.id
      name = v.name
    }
  }
}

output "vlans" {
  description = "Map of created VLANs"
  value = {
    for k, v in maas_vlan.vlan : k => {
      id        = v.id
      vid       = v.vid
      name      = v.name
      fabric_id = v.fabric
    }
  }
}

output "subnets" {
  description = "Map of created subnets"
  value = {
    for k, v in maas_subnet.subnet : k => {
      id      = v.id
      cidr    = v.cidr
      name    = v.name
      vlan_id = v.vlan
    }
  }
}

output "ip_ranges" {
  description = "Map of created IP ranges by subnet"
  value = {
    for k, v in maas_subnet_ip_range.ip_range : k => {
      id       = v.id
      type     = v.type
      start_ip = v.start_ip
      end_ip   = v.end_ip
      subnet   = v.subnet
    }
  }
}
