# Terragrunt Structure - Sunbeam MAAS

This repository uses Terragrunt to manage MAAS and Juju deployment across multiple clouds using Canonical's official MAAS Terraform modules.

## Directory Structure

```
.
├── terragrunt.hcl          # Root configuration
├── common.hcl              # Common variables and tags
└── clouds/                 # Cloud-specific configurations
    └── prod/
        ├── env.hcl         # Production cloud config
        ├── terragrunt.hcl  # Production root config
        ├── juju-bootstrap/ # Juju controller bootstrap (from canonical/maas-terraform-modules)
        ├── maas-setup/     # MAAS installation & setup (from canonical/maas-terraform-modules)
        └── maas-config/    # MAAS configuration (from canonical/maas-terraform-modules)
```

All modules are sourced from [canonical/maas-terraform-modules](https://github.com/canonical/maas-terraform-modules).

## Key Concepts

### External Modules
This repository uses Canonical's official Terraform modules from [maas-terraform-modules](https://github.com/canonical/maas-terraform-modules):

1. **juju-bootstrap** (from `modules/juju-bootstrap`)
   - Bootstraps Juju controller on LXD cloud
   - Outputs: `juju_cloud` (cloud name for use in maas-deploy)
   - Required inputs: `lxd_address`, `lxd_trust_token`, `cloud_name`, `lxd_project`

2. **maas-setup** (from `modules/maas-deploy`)
   - Deploys charmed MAAS (PostgreSQL + MAAS Region)
   - Outputs: `maas_api_url`, `maas_api_key`, `maas_machines`
   - Required inputs: `juju_cloud_name`, `admin_username`, `admin_password`

3. **maas-config** (from `modules/maas-config`)
   - Configures MAAS resources (boot sources, domains, tags, etc.)
   - Required inputs: `maas_url`, `maas_key` (from maas-setup outputs)
   - Optional: boot selections, tags, domains, DNS records, node scripts

### Units
Cloud-specific configurations in `clouds/{cloud}/{unit}/`. Each unit:
- References an external module via `terraform.source` (GitHub URL)
- Provides cloud-specific inputs
- Can define dependencies on other units
- **Currently set to `skip = true`** (do nothing)

### Clouds
Separate cloud deployments (prod, staging, dev, etc.) with:
- Different configurations
- Isolated state files
- Independent lifecycles

## Deployment Flow

The typical deployment order is:

1. **juju-bootstrap** → Creates Juju controller, outputs cloud name
2. **maas-setup** → Deploys MAAS using the Juju cloud, outputs API URL and key
3. **maas-config** → Configures MAAS using the API credentials

**Current Status**: All units are set to `skip = true` and will do nothing when applied.

## Common Commands

### Initialize a unit
```bash
cd clouds/prod/maas-setup
terragrunt init
```

### Plan changes
```bash
cd clouds/prod/maas-setup
terragrunt plan
```

### Apply changes to a single unit
```bash
cd clouds/prod/maas-setup
terragrunt apply
```

### Apply all units in order (respects dependencies)
```bash
cd clouds/prod
terragrunt run-all apply
```

This will automatically apply in the correct order:
1. maas-setup
2. maas-config (after maas-setup)
3. juju-bootstrap (after maas-config)

### Destroy a unit
```bash
cd clouds/prod/maas-setup
terragrunt destroy
```

### View dependency graph
```bash
cd clouds/prod
terragrunt graph-dependencies | dot -Tpng > graph.png
```

### Output values from a unit
```bash
cd clouds/prod/maas-setup
terragrunt output
```

## Dependencies

Units can depend on each other using the `dependency` block. For example, maas-config depends on maas-setup:

```hcl
dependency "maas_setup" {
  config_path = "../maas-setup"
  
  mock_outputs = {
    maas_api_url = "http://mock-maas-api:5240/MAAS"
    maas_api_key = "mock-api-key"
  }
  
  skip_outputs = true
}

inputs = {
  maas_url = dependency.maas_setup.outputs.maas_api_url
  maas_key = dependency.maas_setup.outputs.maas_api_key
}
```

**Typical Dependencies:**
- `maas-setup` depends on `juju-bootstrap` (needs `juju_cloud` name)
- `maas-config` depends on `maas-setup` (needs `maas_api_url` and `maas_api_key`)

Terragrunt will automatically apply dependencies in the correct order.

## Adding a New Cloud

1. Create directory: `clouds/new-cloud/`
2. Copy and customize `env.hcl` from another cloud
3. Copy `terragrunt.hcl` from another cloud
4. Copy unit directories (`juju-bootstrap`, `maas-setup`, `maas-config`)
5. Update cloud-specific parameters in each unit's inputs
6. Remove `skip = true` when ready to deploy

## Adding a New Unit

1. Create directory: `clouds/{cloud}/new-unit/`
2. Create `terragrunt.hcl` referencing an external module or local code
3. Define module source (GitHub URL or local path)
4. Add required inputs
5. Define dependencies if needed
6. Set `skip = true` initially to prevent accidental deployment

## Current Status

All units are currently set to **`skip = true`** and will do nothing when applied:
- `juju-bootstrap`: Skipped - will not bootstrap Juju controller
- `maas-setup`: Skipped - will not deploy MAAS
- `maas-config`: Skipped - will not configure MAAS

**Next Steps to Enable:**
1. Remove `skip = true` from each unit's `terragrunt.hcl`
2. Provide required inputs for each module (see example inputs in the files)
3. Ensure prerequisites are met (LXD cluster, connectivity, etc.)
4. Apply units in order: `juju-bootstrap` → `maas-setup` → `maas-config`

**Module Documentation:**
- [juju-bootstrap](https://github.com/canonical/maas-terraform-modules/tree/main/modules/juju-bootstrap)
- [maas-deploy](https://github.com/canonical/maas-terraform-modules/tree/main/modules/maas-deploy)
- [maas-config](https://github.com/canonical/maas-terraform-modules/tree/main/modules/maas-config)

## Best Practices

1. **DRY Principle**: Keep common configuration in root and cloud-level files
2. **Mock Outputs**: Always provide mock outputs for dependencies (enables `terragrunt plan`)
3. **State Management**: Configure remote state backend when ready
4. **Version Control**: Pin Terraform and provider versions
5. **Testing**: Test in a dev/staging cloud before applying to prod
6. **Dependencies**: Be explicit about dependencies between units
7. **Sensitive Outputs**: Mark sensitive values (like API keys) with `sensitive = true`

## Troubleshooting

### Clear cache
```bash
find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
```

### Re-initialize
```bash
terragrunt init -reconfigure
```

### Debug mode
```bash
terragrunt plan --terragrunt-log-level debug
```
