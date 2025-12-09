variable "maas_api_url" {
  description = "MAAS API URL"
  type        = string
}

variable "maas_api_key" {
  description = "MAAS API Key"
  type        = string
  sensitive   = true
}

provider "maas" {
  api_url = var.maas_api_url
  api_key = var.maas_api_key
}
