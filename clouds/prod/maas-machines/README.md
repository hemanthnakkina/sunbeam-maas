# MAAS Machines Unit

This unit enlists multiple MAAS machines using the `machine` module. Machine configurations are defined in a variables file and dynamically generated into Terraform module calls.

## Usage

### 1. Create your machines configuration file

Copy the example file:

```bash
cd clouds/prod/maas-machines
cp machines.tfvars.example machines.tfvars
```

Edit `machines.tfvars` with your machine details:

```hcl
machines = {
  "compute-01" = {
    power_type      = "ipmi"
    power_address   = "192.168.1.100"
    power_user      = "admin"
    power_pass      = "password"
    power_driver    = "LAN_2_0"
    pxe_mac_address = "52:54:00:12:34:56"
    distro_series   = "jammy"
    zone            = "default"
    tags            = ["compute"]
  }
  
  "storage-01" = {
    power_type      = "manual"
    power_address   = ""
    pxe_mac_address = "52:54:00:ab:cd:ef"
    distro_series   = "jammy"
    tags            = ["storage"]
  }
}
```

### 2. Enable the unit

Edit `terragrunt.hcl` and remove or comment out the skip line

### 3. Apply the configuration to enlist machines

```bash
terragrunt init
terragrunt plan -var-file=machines.tfvars
terragrunt apply -var-file=machines.tfvars
```

## Machine Configuration

Each machine in the `machines` map requires:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `power_type` | string | Yes | Power type (ipmi, virsh, manual, etc.) |
| `power_address` | string | Yes* | Power management address (*empty for manual) |
| `power_user` | string | No | Power management username |
| `power_pass` | string | No | Power management password |
| `power_driver` | string | No | Power driver (e.g., LAN_2_0 for IPMI) |
| `pxe_mac_address` | string | Yes | MAC address for PXE boot |
| `distro_series` | string | No | Ubuntu release (jammy, focal, etc.) |
| `zone` | string | No | Availability zone |
| `pool` | string | No | Resource pool |
| `tags` | list(string) | No | List of tags |
| `user_data` | string | No | Cloud-init user data |
| `hwe_kernel` | string | No | HWE kernel version |
| `network_interfaces` | list(object) | No | Network interface configurations |

## Examples

### IPMI Machines

```hcl
machines = {
  "node-01" = {
    power_type      = "ipmi"
    power_address   = "192.168.1.100"
    power_user      = "admin"
    power_pass      = "secret"
    power_driver    = "LAN_2_0"
    pxe_mac_address = "aa:bb:cc:dd:ee:01"
    distro_series   = "jammy"
    tags            = ["compute"]
  }
}
```

### Manual Power Type

```hcl
machines = {
  "manual-node" = {
    power_type      = "manual"
    power_address   = ""
    pxe_mac_address = "aa:bb:cc:dd:ee:02"
    distro_series   = "jammy"
  }
}
```

### Virtual Machines (virsh)

```hcl
machines = {
  "vm-01" = {
    power_type      = "virsh"
    power_address   = "qemu+ssh://user@host/system"
    pxe_mac_address = "52:54:00:11:22:33"
    distro_series   = "focal"
    tags            = ["virtual"]
  }
}
```

### With Network Configuration

```hcl
machines = {
  "web-01" = {
    power_type      = "ipmi"
    power_address   = "192.168.1.100"
    power_user      = "admin"
    power_pass      = "password"
    pxe_mac_address = "aa:bb:cc:dd:ee:01"
    distro_series   = "jammy"
    network_interfaces = [
      {
        name        = "eth0"
        subnet_cidr = "10.0.0.0/24"
        ip_address  = "10.0.0.10"
      },
      {
        name        = "eth1"
        subnet_cidr = "192.168.1.0/24"
      }
    ]
  }
}
```

### With Cloud-Init User Data

```hcl
machines = {
  "app-01" = {
    power_type      = "ipmi"
    power_address   = "192.168.1.100"
    power_user      = "admin"
    power_pass      = "password"
    pxe_mac_address = "aa:bb:cc:dd:ee:01"
    distro_series   = "jammy"
    user_data       = <<-EOT
      #cloud-config
      packages:
        - docker.io
        - nginx
      runcmd:
        - systemctl enable docker
    EOT
  }
}
```

## How It Works

1. Machine configurations are defined in `machines.tfvars`
2. Terragrunt reads the variables and generates a `machines.tf` file
3. Each machine becomes a separate module call to the `machine` module
4. All machines are enlisted in parallel by Terraform

## Security Notes

- Store `machines.tfvars` securely (add to .gitignore)
- Power passwords are marked as sensitive
- Consider using a secrets manager for production deployments
- Use Terraform/Terragrunt remote state with encryption

## Outputs

Access enlisted machine details:

```bash
# List all machine module outputs
terragrunt output

# Get specific machine details
terragrunt output -json | jq '.machine_compute_01'
```
