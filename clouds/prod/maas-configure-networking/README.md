# MAAS Configure Networking Unit

This unit manages MAAS networking resources including spaces, fabrics, VLANs, and subnets.

## Structure

- `terragrunt.hcl` - Terragrunt configuration that generates main.tf and provider.tf
- `variables.tf` - Variable definitions
- `provider.tf` - MAAS provider configuration (shared with maas-machines)
- `networking.tfvars` - Network configuration (spaces, fabrics, VLANs, subnets)

## Dependencies

- `maas-setup` - Provides MAAS API URL and API key

## Usage

### 1. Configure Network Resources

Edit `networking.tfvars` to define your network topology.

**Important**: Create resources in stages:
1. First run: Create spaces, fabrics, and VLANs (leave `subnets = {}`)
2. Get VLAN IDs: Run `terragrunt output vlans`
3. Second run: Update `networking.tfvars` with actual VLAN IDs and create subnets

### 2. Initialize and Plan

```bash
cd /home/hemanth/repos/github/sunbeam-maas/clouds/prod/maas-networking
terragrunt init
terragrunt plan
```

### 3. Apply Changes

```bash
terragrunt apply
```

### 4. View Outputs

```bash
terragrunt output
```

## Example Workflow

```bash
# Step 1: Create spaces, fabrics, and VLANs
# Edit networking.tfvars to set spaces, fabrics, vlans (keep subnets = {})
terragrunt apply

# Step 2: Get VLAN IDs
terragrunt output vlans

# Step 3: Update networking.tfvars with VLAN IDs in subnet definitions
# Edit networking.tfvars and uncomment subnet configurations with correct vlan_id values

# Step 4: Create subnets
terragrunt apply
```

## Files Generated

- `main.tf` - Module call for maas-networking
- `provider.tf` - MAAS provider configuration
