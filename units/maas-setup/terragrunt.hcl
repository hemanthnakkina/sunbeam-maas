include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git::https://github.com/canonical/maas-terraform-modules.git//modules/maas-deploy?ref=main"
}


inputs = {
  juju_cloud_name          = values.juju_cloud_name
  juju_cloud_region        = values.juju_cloud_region
  ubuntu_version           = try(values.ubuntu_version, "24.04")
  maas_constraints         = try(values.maas_constraints, null)
  postgres_constraints     = try(values.postgres_constraints, null)
  enable_postgres_ha       = try(values.enable_postgres_ha, false)
  enable_maas_ha           = try(values.enable_maas_ha, false)
  lxd_project              = try(values.lxd_project, null)
  charm_postgresql_channel = try(values.charm_postgresql_channel, "16/stable")
  # charm_postgresql_revision    = try(values.charm_postgresql_revision, null)
  # charm_postgresql_config      = try(values.charm_postgresql_config, null)
  # charm_maas_region_channel    = try(values.charm_maas_region_channel, null)
  # charm_maas_region_revision   = try(values.charm_maas_region_revision, null)
  charm_maas_region_config = {
    enable_rack_mode = try(values.enable_rack_mode, false)
  }
  admin_username   = try(values.admin_username, null)
  admin_password   = try(values.admin_password, null)
  admin_email      = try(values.admin_email, null)
  admin_ssh_import = try(values.admin_ssh_import, null)
  # enable_backup                = try(values.enable_backup, false)
  # charm_s3_integrator_channel  = try(values.charm_s3_integrator_channel, null)
  # charm_s3_integrator_revision = try(values.charm_s3_integrator_revision, null)
  # charm_s3_integrator_config   = try(values.charm_s3_integrator_config, null)
  #   s3_ca_chain_file_path        = try(values.s3_ca_chain_file_path, null)
  #   s3_access_key                = try(values.s3_access_key, null)
  #   s3_secret_key                = try(values.s3_secret_key, null)
  #   s3_bucket_postgresql         = try(values.s3_bucket_postgresql, null)
  #   s3_path_postgresql           = try(values.s3_path_postgresql, null)
  #   s3_bucket_maas               = try(values.s3_bucket_maas, null)
  #   s3_path_maas                 = try(values.s3_path_maas, null)
}
