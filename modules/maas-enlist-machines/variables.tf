# MAAS Machine Module Variables

variable "power_type" {
  description = "The power type of the machine (e.g., 'manual', 'ipmi', 'virsh', 'lxd', etc.)"
  type        = string
}

variable "power_parameters" {
  description = "Power parameters specific to the power type as a JSON string"
  type        = string
  sensitive   = true
}

variable "pxe_mac_address" {
  description = "The MAC address of the machine's PXE boot interface (optional if machine already exists in MAAS)"
  type        = string
  default     = null
}

variable "hostname" {
  description = "The hostname to assign to the machine"
  type        = string
  default     = null
}

variable "zone" {
  description = "The availability zone to assign the machine to"
  type        = string
  default     = null
}

variable "architecture" {
  description = "The architecture of the machine (e.g., 'amd64/generic', 'arm64/generic')"
  type        = string
  default     = "amd64/generic"
}
