variable "network_profiles" {
  description = "Network profiles that define common interface configurations"
  type = map(object({
    physical_interfaces = optional(map(object({
      name      = optional(string)
      tags      = optional(list(string), [])
      vlan_id   = optional(number)
      mtu       = optional(number)
      accept_ra = optional(bool)
    })), {})

    bond_interfaces = optional(map(object({
      name                  = string
      parents               = list(string)
      bond_mode             = optional(string, "802.3ad")
      bond_miimon           = optional(number)
      bond_downdelay        = optional(number)
      bond_updelay          = optional(number)
      bond_lacp_rate        = optional(string)
      bond_xmit_hash_policy = optional(string)
      vlan_id               = optional(number)
      tags                  = optional(list(string), [])
      mtu                   = optional(number)
      accept_ra             = optional(bool)
    })), {})

    bridge_interfaces = optional(map(object({
      name        = string
      parent      = optional(string)
      bridge_type = optional(string, "standard")
      bridge_stp  = optional(bool)
      bridge_fd   = optional(number)
      vlan_id     = optional(number)
      tags        = optional(list(string), [])
      mtu         = optional(number)
      accept_ra   = optional(bool)
    })), {})

    vlan_interfaces = optional(map(object({
      name      = optional(string)
      parent    = string
      vlan_id   = number
      fabric    = optional(string)
      tags      = optional(list(string), [])
      mtu       = optional(number)
      accept_ra = optional(bool)
    })), {})

    interface_links = optional(map(object({
      network_interface = string
      subnet_id         = string
      mode              = string # AUTO, DHCP, STATIC, LINK_UP
      default_gateway   = optional(bool, false)
    })), {})
  }))
  default = {}
}

variable "nodes" {
  description = "Map of node configurations with their network interface settings. The map key is used as the machine hostname in MAAS."
  type = map(object({
    network_profile = optional(string) # Reference to a network profile

    physical_interfaces = optional(map(object({
      mac_address = string
      name        = optional(string)
      tags        = optional(list(string), [])
      vlan_id     = optional(number)
      mtu         = optional(number)
      accept_ra   = optional(bool)
    })), {})

    static_ip_addresses = optional(map(object({
      interface_name = string
      subnet_id      = string
      ip_address     = string
    })), {})

    bond_interfaces = optional(map(object({
      name                  = string
      parents               = list(string)
      bond_mode             = optional(string, "802.3ad")
      bond_miimon           = optional(number)
      bond_downdelay        = optional(number)
      bond_updelay          = optional(number)
      bond_lacp_rate        = optional(string)
      bond_xmit_hash_policy = optional(string)
      vlan_id               = optional(number)
      tags                  = optional(list(string), [])
      mtu                   = optional(number)
      accept_ra             = optional(bool)
    })), {})

    bridge_interfaces = optional(map(object({
      name        = string
      parent      = optional(string)
      bridge_type = optional(string, "standard") # standard or ovs
      bridge_stp  = optional(bool)
      bridge_fd   = optional(number)
      vlan_id     = optional(number)
      tags        = optional(list(string), [])
      mtu         = optional(number)
      accept_ra   = optional(bool)
    })), {})

    vlan_interfaces = optional(map(object({
      name      = optional(string)
      parent    = string
      vlan_id   = number
      fabric    = optional(string) # Fabric ID for the VLAN
      tags      = optional(list(string), [])
      mtu       = optional(number)
      accept_ra = optional(bool)
    })), {})

    interface_links = optional(map(object({
      network_interface = string
      subnet_id         = string
      mode              = string # AUTO, DHCP, STATIC, LINK_UP
      ip_address        = optional(string)
      default_gateway   = optional(bool, false)
    })), {})
  }))

  validation {
    condition = alltrue([
      for node_key, node in var.nodes : alltrue([
        for link_key, link in node.interface_links :
        contains(["AUTO", "DHCP", "STATIC", "LINK_UP"], link.mode)
      ])
    ])
    error_message = "Interface link mode must be one of: AUTO, DHCP, STATIC, LINK_UP"
  }

  validation {
    condition = alltrue([
      for node_key, node in var.nodes : alltrue([
        for link_key, link in node.interface_links :
        link.mode != "STATIC" || link.ip_address != null
      ])
    ])
    error_message = "ip_address is required when mode is STATIC"
  }
}

variable "maas_profile" {
  description = "MAAS CLI profile name to use for local-exec provisioners"
  type        = string
  default     = "root"
}
