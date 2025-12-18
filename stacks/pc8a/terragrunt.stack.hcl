
locals {
  deployment = "openstack-pc8a"
  # These files are gitignored to avoid committing sensitive information
  credentials   = jsondecode(read_tfvars_file("${get_repo_root()}/stacks/pc8a/credentials.hcl"))
  profiles      = jsondecode(read_tfvars_file("${get_repo_root()}/stacks/pc8a/profiles.hcl"))
  sunbeam_infra = jsondecode(read_tfvars_file("${get_repo_root()}/stacks/pc8a/sunbeam-infra.hcl"))
  sunbeam_nodes = jsondecode(read_tfvars_file("${get_repo_root()}/stacks/pc8a/sunbeam-nodes.hcl"))
  # Following loops are to append the deployment tag to all VMs and machines
  vm_configurations = {
    for k, v in local.sunbeam_infra.vm_configurations : k => merge(v, {
      tags = distinct(concat(coalesce(v.tags, []), [local.deployment]))
    })
  }
  machines = {
    for k, v in local.sunbeam_nodes.machines : k => merge(v, {
      tags = distinct(concat(coalesce(v.tags, []), [local.deployment]))
    })
  }
}

unit "maas-setup" {
  source = "${get_repo_root()}/units/stub-maas-setup"
  path   = "maas-setup"

  values = {
    maas_api_url = local.credentials.maas_api_url
    maas_api_key = local.credentials.maas_api_key
  }
}

unit "maas-configure-networking" {
  source = "${get_repo_root()}/units/stub-maas-configure-networking"
  path   = "maas-configure-networking"

  values = {
    maas_setup_path = "../maas-setup"
    spaces          = {}
    fabrics         = {}
  }
}

########################################
# ALL MAAS ACTIONS HAVE BEEN PERFORMED #
########################################

# dependencies is a way to express ordering between units
# only use for modules from which you require no outputs

unit "sunbeam-infra" {
  source = "${get_repo_root()}/units/maas-compose-vms"
  path   = "sunbeam-infra"

  values = {
    maas_setup_path = "../maas-setup"
    dependencies = [
      "../maas-configure-networking"
    ],
    vm_configurations = local.vm_configurations
  }
}

unit "sunbeam-nodes" {
  source = "${get_repo_root()}/units/maas-enlist-machines"
  path   = "sunbeam-nodes"

  values = {
    maas_setup_path = "../maas-setup"
    dependencies = [
      "../maas-configure-networking"
    ],
    machines = local.machines
  }
}

unit "sunbeam-nodes-storage" {
  source = "${get_repo_root()}/units/maas-configure-nodes-storage"
  path   = "sunbeam-nodes-storage"
  values = {
    maas_setup_path = "../maas-setup"
    dependencies = [
      "../sunbeam-nodes"
    ],
    storage_profiles = local.profiles.storage_profiles
    nodes            = local.sunbeam_nodes.nodes
  }
}

unit "sunbeam-nodes-networking" {
  source = "${get_repo_root()}/units/maas-configure-nodes-networking"
  path   = "sunbeam-nodes-networking"
  values = {
    maas_setup_path = "../maas-setup"
    dependencies = [
      "../sunbeam-nodes"
    ],
    network_profiles = local.profiles.network_profiles
    nodes            = local.sunbeam_nodes.nodes
  }
}
