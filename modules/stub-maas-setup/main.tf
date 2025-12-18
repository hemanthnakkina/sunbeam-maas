variable "maas_api_url" {
  description = "Api url to connect to MAAS"
  type        = string
}

variable "maas_api_key" {
  description = "Api key to connect to MAAS"
  type        = string
}

output "maas_api_url" {
  value = var.maas_api_url
}

output "maas_api_key" {
  value = var.maas_api_key
}
