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
variable "tags" {
  description = <<-EOT
    Map of tags to create. Key is the tag name, value is tag configuration.
    Each tag configuration includes:
    - machines: List of machine IDs associated with the tag
    - definition: Tag definition (optional)
    - kernel_opts: Kernel options for the tag (optional)
  EOT
  type = map(object({
    machines    = list(string)
    definition  = optional(string)
    kernel_opts = optional(string)
  }))
  default = {}
}
