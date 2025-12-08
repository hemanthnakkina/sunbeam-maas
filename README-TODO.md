# TODO Items

## Modules and Units

- [ ] Define module and unit to enlist machines (Not tested yet)
- [x] Define module and unit to configure networking (Verified)
- [ ] Define module and unit to configure machine/node for networking (Verified a bit)

## Open Questions

- [] Zone definition will be part of maas-config?
- [] Add min_hwe_kernel to maas_machine? yes
- [] physical_interfaces are made as datasource in configure_node. It fails if
     the datasource is made as resource. In this case we are dealing with interface
     names, we need to change that and deal with MAC address.
