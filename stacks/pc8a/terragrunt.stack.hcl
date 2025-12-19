
locals {
  deployment = ""
  # These files are gitignored to avoid committing sensitive information
  credentials   = jsondecode(read_tfvars_file("${get_repo_root()}/stacks/pc8a/credentials.hcl"))
  profiles      = jsondecode(read_tfvars_file("${get_repo_root()}/stacks/pc8a/profiles.hcl"))
  sunbeam_infra = jsondecode(read_tfvars_file("${get_repo_root()}/stacks/pc8a/sunbeam-infra.hcl"))
  sunbeam_nodes = jsondecode(read_tfvars_file("${get_repo_root()}/stacks/pc8a/sunbeam-nodes.hcl"))
  # Following loops are to append the deployment tag to all VMs and machines
  vm_configurations = local.sunbeam_infra.vm_configurations
  machines          = local.sunbeam_nodes.machines
  isolcpus          = "96-127,352-383,224-255,480-511"
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

unit "sunbeam-nodes-tagging" {
  source = "${get_repo_root()}/units/maas-tag-machines"
  path   = "sunbeam-nodes-tagging"
  values = {
    maas_setup_path = "../maas-setup"
    dependencies = [
      "../sunbeam-nodes",
      "../sunbeam-infra"
    ],
    tags = {
      isocpu = {
        machines    = keys(local.sunbeam_nodes.machines)
        kernel_opts = "isolcpus=domain,managed_irq,${local.isolcpus} nohz_full=${local.isolcpus} rcu_nocbs=${local.isolcpus} rcu_nocb_poll"
      }
      hugepages = {
        machines    = keys(local.sunbeam_nodes.machines)
        kernel_opts = "transparent_hugepage=never default_hugepagesz=1G hugepagesz=1G hugepages=node0:1000,node1:1000"
      }
      openstack-pc8a = {
        machines = concat(
          keys(local.sunbeam_nodes.machines),
          # This can't work because we don't have the VM names here.
          # keys(local.vm_configurations)
        )
      }
    }
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
