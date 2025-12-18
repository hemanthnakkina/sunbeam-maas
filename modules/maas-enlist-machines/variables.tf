variable "maas_url" {
  description = "MAAS API URL"
  type        = string
}

variable "maas_key" {
  description = "MAAS API key for authentication"
  type        = string
  sensitive   = true
}

# Machine Definitions
variable "machines" {
  description = <<-EOT
    Map of machines to enlist. Key is the hostname, value is machine configuration.
    Each machine configuration includes:
    - power_type: Power type (ipmi, virsh, manual, etc.)
    - power_address: Power management address/URL
    - power_user: Power management username (optional)
    - power_pass: Power management password (optional)
    - power_driver: Power driver type, e.g., LAN_2_0 for IPMI (optional)
    - power_boot_type: Boot type for power management (e.g., 'efi', 'legacy') (optional)
    - cipher_suite_id: Cipher suite ID for power management (optional)
    - pxe_mac_address: MAC address for PXE boot
    - distro_series: Ubuntu release (jammy, focal, etc.) (optional)
    - hostname: Hostname for the machine (optional, defaults to map key)
    - zone: Availability zone (optional)
    - architecture: Machine architecture, default 'amd64/generic' (optional)
    - pool: Resource pool (optional)
    - tags: List of tags (optional)
    - user_data: Cloud-init user data (optional)
    - hwe_kernel: HWE kernel version (optional)
    - network_interfaces: List of network interface configurations (optional)
  EOT
  type = map(object({
    power_type      = string
    power_address   = string
    power_user      = optional(string)
    power_pass      = optional(string)
    power_driver    = optional(string)
    power_boot_type = optional(string)
    cipher_suite_id = optional(number)
    pxe_mac_address = string
    distro_series   = optional(string)
    hostname        = optional(string)
    zone            = optional(string)
    architecture    = optional(string)
    pool            = optional(string)
    tags            = optional(list(string))
    user_data       = optional(string)
    hwe_kernel      = optional(string)
    network_interfaces = optional(list(object({
      name        = string
      subnet_cidr = string
      ip_address  = optional(string)
    })))
  }))
  default = {}
}
