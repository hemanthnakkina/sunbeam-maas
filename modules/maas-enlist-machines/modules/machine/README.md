# MAAS Enlist Machines Module

This module wraps the [canonical/maas](https://registry.terraform.io/providers/canonical/maas/latest/docs/resources/machine) provider's machine resource to manage physical or virtual machines in MAAS.

## Features

- Add machines to MAAS with power configuration
- Deploy machines with specific OS versions and kernels
- Configure network interfaces
- Assign machines to zones and pools
- Apply tags for organization

## Usage

### Basic Example - Manual Power Type

```hcl
module "machine" {
  source = "../../modules/machine"

  power_type = "manual"
  power_parameters = jsonencode({})
  
  pxe_mac_address = "52:54:00:12:34:56"
  
  deploy_hostname      = "node01"
  deploy_distro_series = "jammy"
  deploy_zone          = "default"
  deploy_tags          = ["compute", "production"]
}
```

### IPMI Power Type

```hcl
module "machine_ipmi" {
  source = "../../modules/machine"

  power_type = "ipmi"
  power_parameters = jsonencode({
    power_address  = "192.168.1.100"
    power_user     = "admin"
    power_pass     = "password"
    power_driver   = "LAN_2_0"
  })
  
  pxe_mac_address = "52:54:00:12:34:57"
  
  deploy_hostname      = "compute01"
  deploy_distro_series = "jammy"
  deploy_pool          = "production"
  deploy_zone          = "zone-1"
}
```

### LXD/KVM Virtual Machine

```hcl
module "machine_virsh" {
  source = "../../modules/machine"

  power_type = "virsh"
  power_parameters = jsonencode({
    power_address = "qemu+ssh://user@192.168.1.50/system"
    power_id      = "vm-name"
  })
  
  pxe_mac_address = "52:54:00:ab:cd:ef"
  
  deploy_hostname      = "test-vm"
  deploy_distro_series = "focal"
  deploy_hwe_kernel    = "hwe-20.04"
}
```

### With Network Configuration

```hcl
module "machine_network" {
  source = "../../modules/machine"

  power_type       = "manual"
  power_parameters = jsonencode({})
  pxe_mac_address  = "52:54:00:11:22:33"
  
  deploy_hostname      = "worker01"
  deploy_distro_series = "jammy"
  
  network_interfaces = [
    {
      name        = "eth0"
      subnet_cidr = "10.0.0.0/24"
      ip_address  = "10.0.0.100"
    },
    {
      name        = "eth1"
      subnet_cidr = "192.168.1.0/24"
    }
  ]
}
```

### With Cloud-Init User Data

```hcl
module "machine_cloudinit" {
  source = "../../modules/machine"

  power_type       = "manual"
  power_parameters = jsonencode({})
  pxe_mac_address  = "52:54:00:44:55:66"
  
  deploy_hostname      = "app-server"
  deploy_distro_series = "jammy"
  
  deploy_user_data = <<-EOT
    #cloud-config
    packages:
      - docker.io
      - nginx
    runcmd:
      - systemctl enable docker
      - systemctl start docker
  EOT
}
```

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `power_type` | Power type (manual, ipmi, virsh, lxd, etc.) | string | Yes | - |
| `power_parameters` | Power parameters as JSON string | string | Yes | - |
| `pxe_mac_address` | MAC address for PXE boot | string | No | null |
| `deploy_hostname` | Hostname to set on deployment | string | No | null |
| `deploy_tags` | Tags to apply | list(string) | No | null |
| `deploy_zone` | Availability zone | string | No | null |
| `deploy_pool` | Resource pool | string | No | null |
| `deploy_user_data` | Cloud-init user data | string | No | null |
| `deploy_distro_series` | Ubuntu release (jammy, focal, etc.) | string | No | null |
| `deploy_hwe_kernel` | HWE kernel version | string | No | null |
| `deploy_min_hwe_kernel` | Minimum HWE kernel | string | No | null |
| `network_interfaces` | Network interface configuration | list(object) | No | null |

## Outputs

| Name | Description |
|------|-------------|
| `id` | MAAS machine system ID |
| `hostname` | Machine hostname |
| `fqdn` | Fully qualified domain name |
| `zone` | Availability zone |
| `pool` | Resource pool |
| `tags` | Applied tags |
| `cpu_count` | Number of CPU cores |
| `memory` | RAM in MB |
| `ip_addresses` | List of IP addresses |
| `power_type` | Configured power type |

## Power Types

Common power types supported by MAAS:

- `manual` - Manual power management
- `ipmi` - IPMI (Intelligent Platform Management Interface)
- `virsh` - libvirt/KVM (virsh)
- `lxd` - LXD containers
- `wedge` - Facebook Wedge switches
- `amt` - Intel AMT
- `dli` - Digital Loggers, Inc. PDU
- `hmc` - IBM Hardware Management Console

Refer to [MAAS documentation](https://maas.io/docs/power-management-reference) for complete list and parameters.

## Requirements

- MAAS provider configured with API URL and key
- Network connectivity to MAAS API
- Appropriate power management access for the specified power type

## Notes

- The `power_parameters` must be a valid JSON string matching the requirements of the chosen `power_type`
- The `pxe_mac_address` is optional if the machine already exists in MAAS
- When deploying, the machine will be commissioned first if not already commissioned
- Network interfaces will be configured during deployment
