# Common configuration shared across all clouds
locals {
  project_name = "sunbeam-maas"

  # Common tags applied to all resources
  common_tags = {
    Project    = "sunbeam-maas"
    ManagedBy  = "Terragrunt"
    Repository = "sunbeam-maas"
  }
}
