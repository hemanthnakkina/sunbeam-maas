# TODO Items

- [ ] Configure Infra nodes
- [ ] Setup LXD HA

- [ ] Juju bootstrap on LXD
      Unit should come from https://github.com/skatsaounis/infrastructure-catalog
      Module should be imported from https://github.com/canonical/maas-terraform-modules
- [ ] maas-setup
      Same as above
- [ ] maas-config
      Same as above

- [ ] Register infra node LXD in maas

- [x] maas-configure-networking
      Create fabrics, subnets, vlans
- [x] maas-enlist-machines
      Add machines to MAAS. Yet to test
- [x] maas-configure-nodes
      Configure networking on nodes
- [x] maas-configure-nodes-storage
      Configure storage on nodes
      This unit should be moved as part of maas-configure-nodes after testing
      RAIDS not working, LVS without mount options not working
      https://github.com/canonical/terraform-provider-maas/issues/391
      https://github.com/canonical/terraform-provider-maas/issues/392
- [ ] Sunbeam specific tags etc
      To check if we need separate module or just include them in the above ones
- [ ] Compose juju controller and sunbeam infra VMs
      Not started

- [ ] Deploy COS on VMs

- [ ] Terraform module to deploy sunbeam and enable all features
      Not started


## Open Questions

- [ ] Zone definition will be part of maas-config?
- [ ] Add min_hwe_kernel to maas_machine? yes
- [ ] physical_interfaces are made as datasource in configure_node. It fails if
    the datasource is made as resource. In this case we are dealing with interface
    names, we need to change that and deal with MAC address.
- [ ] Destroy of maas_block_device removes the storage from maas. Is this expected?
- [ ] How to provide commissioning scripts if required?

