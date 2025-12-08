# MAAS Networking Configuration Variables

# MAAS Provider Configuration
variable "maas_api_url" {
  description = "MAAS API URL"
  type        = string
}

variable "maas_api_key" {
  description = "MAAS API key"
  type        = string
  sensitive   = true
}

variable "maas_api_version" {
  description = "MAAS API version"
  type        = string
  default     = "2.0"
}

# Networking configuration variables
variable "spaces" {
  description = "Map of spaces to create"
  type = map(object({
    description = optional(string)
  }))
  default = {}
}

variable "fabrics" {
  description = "Map of fabrics with nested VLANs and subnets"
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
