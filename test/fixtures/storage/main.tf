variable "maas_api_url" {
  description = "MAAS API URL"
  type        = string
  default     = "http://localhost:5240/MAAS"
}

variable "maas_api_key" {
  description = "MAAS API Key"
  type        = string
  default     = "test:consumer:secret"
}

variable "storage_profiles" {
  description = "Storage profiles"
  type        = any
  default     = {}
}

variable "nodes" {
  description = "Nodes configuration"
  type        = any
  default     = {}
}

provider "maas" {
  api_url = var.maas_api_url
  api_key = var.maas_api_key
}

module "storage" {
  source = "../../../modules/maas-configure-nodes-storage"

  storage_profiles = var.storage_profiles
  nodes            = var.nodes
}

output "block_devices" {
  value = module.storage.block_devices
}

output "raids" {
  value = module.storage.raids
}

output "volume_groups" {
  value = module.storage.volume_groups
}

output "logical_volumes" {
  value = module.storage.logical_volumes
}
