# MAAS Configure Networking Module Variables

# Spaces configuration
variable "spaces" {
  description = <<-EOT
    Map of spaces to create. Key is the space name, value includes:
    - description: Optional description of the space
  EOT
  type = map(object({
    description = optional(string)
  }))
  default = {}
}

# Fabrics configuration with nested VLANs and subnets
variable "fabrics" {
  description = <<-EOT
    Map of fabrics with nested VLANs and subnets. Key is the fabric name, value includes:
    - vlans: List of VLANs in this fabric, each containing:
      - vid: VLAN ID
      - space: Space name (optional)
      - dhcp_on: Enable DHCP (optional, default: false)
      - mtu: MTU value (optional, default: 1500)
      - subnets: Map of subnets in this VLAN, each containing:
        - cidr: Subnet CIDR
        - gateway_ip: Gateway IP (optional)
        - dns_servers: List of DNS servers (optional)
        - reserved: Map of IP ranges, each containing:
          - start_ip: Starting IP
          - end_ip: Ending IP
          - type: Range type (optional, default: "reserved")
  EOT
  type = map(object({
    vlans = list(object({
      vid     = number
      space   = optional(string)
      dhcp_on = optional(bool)
      mtu     = optional(number)
      subnets = map(object({
        cidr        = string
        gateway_ip  = optional(string)
        dns_servers = optional(list(string))
        reserved = optional(map(object({
          start_ip = string
          end_ip   = string
          type     = optional(string)
        })))
      }))
    }))
  }))
  default = {}
}
