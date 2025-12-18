variable "maas_url" {
  description = "The MAAS URL in the format of: http://127.0.0.1:5240/MAAS"
  type        = string
}

variable "maas_key" {
  description = "The MAAS API key"
  type        = string
}

variable "vm_configurations" {
  description = "Map of VM configurations to create. Each configuration can specify a count for multiple instances."
  type = map(object({
    vm_host         = list(string)
    hostname_prefix = optional(string)
    count           = number
    cores           = number
    pinned_cores    = optional(list(number))
    memory          = number
    pool            = optional(string)
    zone            = optional(list(string))
    storage_disks = optional(list(object({
      size_gigabytes = number
      pool           = optional(string)
    })))
    network = optional(list(object({
      name        = string
      fabric      = optional(string)
      vlan        = optional(string)
      subnet_cidr = optional(string)
      ip_address  = optional(string)
    })))
    tags = optional(list(string), [])
  }))

  validation {
    condition = alltrue([
      for k, v in var.vm_configurations : v.count > 0
    ])
    error_message = "Count must be greater than 0 for all VM configurations."
  }

  validation {
    condition = alltrue([
      for k, v in var.vm_configurations : v.cores > 0
    ])
    error_message = "Cores must be greater than 0 for all VM configurations."
  }

  validation {
    condition = alltrue([
      for k, v in var.vm_configurations : v.memory > 0
    ])
    error_message = "Memory must be greater than 0 for all VM configurations."
  }
}
